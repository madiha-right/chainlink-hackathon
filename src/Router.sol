// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { VersionedInitializable } from "../lib/upgradeability/VersionedInitializable.sol";

import { Errors } from "./lib/Errors.sol";
import { DataTypes } from "./lib/DataTypes.sol";
import { ConnectorsCall } from "./lib/ConnectorsCall.sol";
import { PercentageMath } from "./lib/PercentageMath.sol";

import { IRouter } from "./interfaces/IRouter.sol";
import { IAccount } from "./interfaces/IAccount.sol";
import { IConnectors } from "./interfaces/IConnectors.sol";
import { IVaults } from "./interfaces/IVaults.sol";
import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

/**
 * @title Router contract
 * @notice Main point of interaction with the protocol
 * - Users can:
 *   # Open position
 *   # Close position
 *   # Create acconut
 */
contract Router is VersionedInitializable, IRouter {
  using SafeERC20 for IERC20;
  using ConnectorsCall for IAddressesProvider;
  using PercentageMath for uint256;

  /* ============ Immutables ============ */

  // The contract by which all other contact addresses are obtained.
  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  /* ============ Constants ============ */

  uint256 public constant ROUTER_REVISION = 0x1;

  /* ============ State Variables ============ */

  // Fee of the protocol, expressed in bps
  uint256 public override fee;

  // Count of user position
  mapping(address => uint256) public positionsIndex;

  // Map of key (user address and position index) to position (key => postion)
  mapping(bytes32 => DataTypes.Position) public positions;

  // Map of users address and their account (userAddress => userAccount)
  mapping(address => address) public accounts;

  // Map of assets and users addresses and their balance (asset => userAddress => balance)
  mapping(address => mapping(address => uint256)) public balances;

  /* ============ Modifiers ============ */

  /// @dev Only pool configurator can call functions marked by this modifier.
  modifier onlyConfigurator() {
    if (ADDRESSES_PROVIDER.getConfigurator() != msg.sender) revert Errors.CallerNotConfigurator();
    _;
  }

  /* ============ Constructor ============ */

  /**
   * @dev Constructor.
   * @param provider The address of the AddressesProvider contract
   */
  constructor(IAddressesProvider provider) {
    if (address(provider) == address(0)) revert Errors.AddressIsZero();
    ADDRESSES_PROVIDER = provider;
  }

  /* ============ Initializer ============ */

  /**
   * @notice Initializes the Router.
   * @dev Function is invoked by the proxy contract when the Router contract is added to the
   * AddressesProvider.
   * @dev Caching the address of the AddressesProvider in order to reduce gas consumption on subsequent operations
   * @param provider The address of the AddressesProvider
   */
  function initialize(address provider) external virtual initializer {
    if (provider != address(ADDRESSES_PROVIDER)) revert Errors.InvalidAddressProvider();
    fee = 50; // 0.5%
  }

  /* ============ External Functions ============ */

  /// @dev See {IRouter-delegate}.
  function delegate(address asset, uint256 amount) external {
    if (amount <= 0) revert Errors.InvalidAmountAction();

    IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
    balances[asset][msg.sender] += amount;

    _depositToVault(asset, amount);
  }

  /// @dev See {IRouter-undelegate}.
  function undelegate(address asset, uint256 amount) external {
    if (amount > balances[asset][msg.sender]) revert Errors.InsufficientBalance();

    balances[asset][msg.sender] -= amount;

    _withdrawFromVault(asset, amount, msg.sender);
  }

  /// @dev See {IRouter-setFee}.
  function setFee(uint256 _fee) external override onlyConfigurator {
    if (fee <= 0) revert Errors.InvalidFeeAmount();
    fee = _fee;
  }

  /// @dev See {IRouter-openPosition}.
  function openPosition(DataTypes.Position memory position, bytes calldata data) external override {
    IERC20(position.collateralAsset).safeTransferFrom(msg.sender, address(this), position.collateralAmount);
    _openPosition(position, data);
  }

  /// @dev See {IRouter-closePosition}.
  function closePosition(bytes32 key, bytes calldata data) external {
    DataTypes.Position memory position = positions[key];
    if (msg.sender != position.account) revert Errors.CallerNotPositionOwner();

    address account = accounts[msg.sender];
    if (account == address(0)) revert Errors.AccountDoesNotExist();

    IAccount(account).closePosition(key, data);
    _depositToVault(position.collateralAsset, position.collateralAmount);

    emit ClosePosition(key, account, position);
    delete positions[key];
  }

  // solhint-disable-next-line
  receive() external payable { }

  /* ============ Public Functions ============ */

  /// @dev See {IRouter-getOrCreateAccount}.
  function getOrCreateAccount(address owner) public override returns (address) {
    if (owner != msg.sender) revert Errors.CallerNotAccountOwner();
    address _account = address(accounts[owner]);

    if (_account == address(0)) {
      _account = Clones.cloneDeterministic(ADDRESSES_PROVIDER.getAccountProxy(), bytes32(abi.encodePacked(owner)));
      accounts[owner] = _account;
      IAccount(_account).initialize(owner, ADDRESSES_PROVIDER);
      emit AccountCreated(_account, owner);
    }

    return _account;
  }

  /// @dev See {IRouter-getKey}.
  function getKey(address account, uint256 index) public pure override returns (bytes32) {
    return keccak256(abi.encodePacked(account, index));
  }

  /// @dev See {IRouter-predictDeterministicAddress}.
  function predictDeterministicAddress(address owner) public view override returns (address predicted) {
    return Clones.predictDeterministicAddress(
      ADDRESSES_PROVIDER.getAccountProxy(), bytes32(abi.encodePacked(owner)), address(this)
    );
  }

  /// @dev See {IRouter-getFeeAmount}.
  function getFeeAmount(uint256 amount) public view override returns (uint256 feeAmount) {
    if (amount <= 0) revert Errors.InvalidChargeAmount();
    feeAmount = amount.mulTo(fee);
  }

  /* ============ Private Functions ============ */

  /**
   * @dev Create user account if user doesn't have it. Update position index and position state.
   * Call openPosition on the user account proxy contract.
   */
  function _openPosition(DataTypes.Position memory position, bytes calldata data) private {
    if (position.account != msg.sender) revert Errors.CallerNotPositionOwner();

    address account = getOrCreateAccount(msg.sender);

    address owner = position.account;
    uint256 index = positionsIndex[owner] += 1;
    positionsIndex[owner] = index;

    bytes32 key = getKey(owner, index);
    positions[key] = position;

    // collateral amount + borrowing power delegation amount
    IERC20(position.collateralAsset).forceApprove(account, position.collateralAmount * 2);

    _withdrawFromVault(position.collateralAsset, position.collateralAmount, address(this));

    IAccount(account).openPosition(position, data);

    // Get the position on the key because, update it in the process of creating
    emit OpenPosition(key, account, index, positions[key]);
  }

  /**
   * @dev Deposit asset to corresposding vault.
   * @param asset Asset to deposit.
   * @param amount Amount to deposit.
   */
  function _depositToVault(address asset, uint256 amount) private {
    address vaults = ADDRESSES_PROVIDER.getVaults();
    address vault = IVaults(vaults).vaults(asset);

    if (vault == address(0)) revert Errors.VaultDoesNotExist();

    if (IERC20(asset).allowance(address(this), vault) < amount) {
      IERC20(asset).forceApprove(vault, type(uint256).max);
    }

    IERC4626(vault).deposit(amount, address(this));
  }

  /**
   * @dev Withdraw asset from corresposding vault.
   * @param asset Asset to withdraw.
   * @param amount Amount to withdraw.
   * @param receiver Receiver of the withdrawn amount of asset.
   */
  function _withdrawFromVault(address asset, uint256 amount, address receiver) private {
    address vaults = ADDRESSES_PROVIDER.getVaults();
    address vault = IVaults(vaults).vaults(asset);

    if (vault == address(0)) revert Errors.VaultDoesNotExist();

    IERC4626(vault).withdraw(amount, receiver, address(this));
  }

  /**
   * @notice Returns the version of the Router contract.
   * @return The version is needed to update the proxy.
   */
  function getRevision() internal pure virtual override returns (uint256) {
    return ROUTER_REVISION;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import { Ccip } from "./Ccip.sol";

import { Errors } from "./lib/Errors.sol";
import { DataTypes } from "./lib/DataTypes.sol";
import { PercentageMath } from "./lib/PercentageMath.sol";
import { ConnectorsCall } from "./lib/ConnectorsCall.sol";

import { IRouter } from "./interfaces/IRouter.sol";
import { IAccount } from "./interfaces/IAccount.sol";
import { IConnectors } from "./interfaces/IConnectors.sol";
import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

/**
 * @title Account
 * @notice Contract used as implimentation user account.
 * @dev Interaction with contracts is carried out by means of calling the proxy contract.
 */
contract AccountV1 is Initializable, IAccount {
  using SafeERC20 for IERC20;
  using ConnectorsCall for IAddressesProvider;
  using Address for address;
  using PercentageMath for uint256;

  /* ============ Immutables ============ */

  // The contract by which all other contact addresses are obtained.
  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  /* ============ State Variables ============ */

  address private _owner;

  /* ============ Modifiers ============ */

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    if (_owner != msg.sender) revert Errors.CallerNotAccountOwner();
    _;
  }

  /**
   * @dev Throws if called by any account other than the router contract.
   */
  modifier onlyRouter() {
    if (msg.sender != address(ADDRESSES_PROVIDER.getRouter())) revert Errors.CallerNotRouter();
    _;
  }

  /* ============ Initializer ============ */

  /**
   * @dev Constructor.
   * @param provider The address of the AddressesProvider contract
   */
  constructor(address provider) {
    ADDRESSES_PROVIDER = IAddressesProvider(provider);
  }

  /// @dev See {IAccount-initialize}.
  function initialize(address user, IAddressesProvider provider) public override initializer {
    if (ADDRESSES_PROVIDER != provider) revert Errors.InvalidAddressProvider();
    _owner = user;
  }

  /* ============ External Functions ============ */

  /// @dev See {IAccount-openPosition}.
  function openPosition(DataTypes.Position memory position, bytes calldata data) external override onlyRouter {
    if (position.account != _owner) revert Errors.CallerNotPositionOwner();
    // collateral amount + borrowing power delegation amount
    IERC20(position.collateralAsset).safeTransferFrom(msg.sender, address(this), position.collateralAmount * 2);

    // _chargeFee(position.collateralAmount, position.collateralAsset);
    (string[] memory _targetNames, bytes[] memory _datas) = abi.decode(data, (string[], bytes[]));

    if (!_compare(position.delegationTargetName, _targetNames[0])) revert Errors.InvalidDelegateTargetName();

    ADDRESSES_PROVIDER.connectorCall(_targetNames[0], _datas[0]); // supply delegated assets

    if (position.destinationChainSelector != 0) {
      address ccip = ADDRESSES_PROVIDER.getCcip();
      IERC20(position.collateralAsset).safeTransfer(ccip, position.collateralAmount);
      Ccip(payable(ccip)).sendMessagePayLink(
        position.destinationChainSelector,
        position.destinationReceiver,
        data,
        position.collateralAsset,
        position.collateralAmount
      );
    } else {
      ADDRESSES_PROVIDER.connectorCall(_targetNames[1], _datas[1]); // deposit collateral
      ADDRESSES_PROVIDER.connectorCall(_targetNames[2], _datas[2]); // borrow debt
    }
  }

  /// @dev See {IAccount-closePosition}.
  function closePosition(DataTypes.Position memory position, bytes calldata data) external onlyRouter {
    if (position.account != _owner) revert Errors.CallerNotPositionOwner();

    (string[] memory _targetNames, bytes[] memory _datas, bytes memory params) =
      abi.decode(data, (string[], bytes[], bytes)); // params = (user, collateralAsset, collateralAmount, repayAmount, PositionType);

    if (!_compare(position.delegationTargetName, _targetNames[0])) revert Errors.InvalidDelegateTargetName();

    ADDRESSES_PROVIDER.connectorCall(_targetNames[0], _datas[0]); // redeem delegated assets

    if (position.destinationChainSelector != 0) {
      (,,, uint256 repayAmount,) = abi.decode(params, (address, address, uint256, uint256, IRouter.PositionType));

      address ccip = ADDRESSES_PROVIDER.getCcip();
      Ccip(payable(ccip)).sendMessagePayLink(
        position.destinationChainSelector, position.destinationReceiver, data, position.debtAsset, repayAmount
      );
    } else {
      ADDRESSES_PROVIDER.connectorCall(_targetNames[1], _datas[1]); // repay debt
      ADDRESSES_PROVIDER.connectorCall(_targetNames[2], _datas[2]); // withdraw collateral with interest
      IERC20(position.collateralAsset).safeTransfer(msg.sender, position.collateralAmount); // only transfer collateral amount to router(interest is not included)
    }
  }

  /// @dev See {IAccount-closePosition}.
  function claimTokens(address token, uint256 amount) external override onlyOwner {
    if (amount == type(uint256).max) {
      amount = IERC20(token).balanceOf(address(this));
    }

    IERC20(token).safeTransfer(_owner, amount);

    emit ClaimedTokens(token, _owner, amount);
  }

  /// @dev See {IAccount-handleLoan}.
  function handleLoan(string[] memory targetNames, bytes[] memory datas) external onlyRouter {
    ADDRESSES_PROVIDER.connectorCall(targetNames[1], datas[1]); // deposit collateral or repay debt
    ADDRESSES_PROVIDER.connectorCall(targetNames[2], datas[2]); // borrow debt or withdraw collateral
  }

  // solhint-disable-next-line
  receive() external payable { }

  /* ============ Private Functions ============ */

  /**
   * @dev Internal function for the charge fee for the using protocol.
   * @param amount Position amount.
   * @param token Position token.
   */
  function _chargeFee(uint256 amount, address token) private {
    uint256 feeAmount = _getRouter().getFeeAmount(amount);
    IERC20(token).safeTransfer(ADDRESSES_PROVIDER.getTreasury(), feeAmount);
  }

  function _isConnector(string memory name) private view returns (address) {
    address connectors = ADDRESSES_PROVIDER.getConnectors();
    if (connectors == address(0)) revert Errors.AddressIsZero();

    (bool isOk, address connector) = IConnectors(connectors).isConnector(name);
    if (!isOk) revert Errors.NotConnector();

    return connector;
  }

  /**
   * @dev Returns an instance of the router class.
   * @return Returns current router contract.
   */
  function _getRouter() private view returns (IRouter) {
    return IRouter(ADDRESSES_PROVIDER.getRouter());
  }

  function _compare(string memory str1, string memory str2) public pure returns (bool) {
    if (bytes(str1).length != bytes(str2).length) {
      return false;
    }
    return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
  }
}

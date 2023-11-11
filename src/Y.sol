// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import { IY } from "./interfaces/IY.sol";
import { IConnector } from "./interfaces/IConnector.sol";

contract Y is IY, Ownable {
  using SafeERC20 for IERC20;

  uint256 private _vaultsCount;
  // the number of yield sources supported
  uint256 private _connectorsCount;

  // asset => vault
  mapping(address => IERC4626) private _vaults;
  // the list of the available vaults
  mapping(uint256 => address) private _vaultsList;
  // the list of the available connectors(which connects to sources), structured as a mapping for gas savings reasons
  mapping(uint256 => address) private _connectorsList;

  // asset => user => balance
  mapping(address => mapping(address => uint256)) private _balances;

  constructor() {}

  function depositToVault(address asset, uint256 amount) external {
    IERC4626 vault = _vaults[asset];
    _balances[asset][msg.sender] += amount;

    IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

    if (IERC20(asset).allowance(address(this), address(vault)) < amount) {
      IERC20(asset).safeApprove(address(vault), type(uint256).max);
    }

    vault.deposit(amount, address(this));
  }

  function withdrawFromVault(address asset, uint256 amount) external {
    require(_balances[asset][msg.sender] >= amount, "insufficient balance");

    IERC4626 vault = _vaults[asset];
    _balances[asset][msg.sender] -= amount;

    vault.withdraw(amount, address(this), address(this));

    IERC20(asset).safeTransfer(msg.sender, amount);
  }

  // need approval for the supply asset
  function zapDepositAndBorrow(
    address supplyAsset,
    address collateralAsset,
    uint256 collateralAmount,
    uint256 supplyConnectorIdx,
    address debtAsset,
    uint256 debtAmount,
    uint256 debtConnectorIdx
  ) external {
    address supplyConnector = _connectorsList[supplyConnectorIdx];
    address debtConnector = _connectorsList[debtConnectorIdx];


    require(supplyConnector != address(0), "connector not found at index");
    require(debtConnector != address(0), "connector not found at index");

    (address underlying, IERC4626 vault) = _supplyToSource(
      supplyAsset,
      collateralAmount,
      msg.sender,
      supplyConnector
    );

    require(address(vault) != address(0), "vault not found at index");

    // get shares to withdraw from yVault
    uint256 shares = vault.convertToShares(collateralAmount);

    vault.redeem(shares, debtConnector, address(this));
    console.log("redeem successs");

    _depositAndBorrow(
      underlying,
      collateralAsset,
      collateralAmount,
      debtAsset,
      debtAmount,
      debtConnector,
      msg.sender
    );
    console.log("CONGRATS!! SUCCESS ALL");
  }

  function balanceOf(address asset, address owner) external view returns (uint256) {
    return _balances[asset][owner];
  }

  /**
   * @dev Returns the list of the active vaults
   **/
  function getVaultsList() external view returns (address[] memory) {
    address[] memory _activeVaults = new address[](_vaultsCount);

    for (uint256 i = 0; i < _activeVaults.length; i++) {
      _activeVaults[i] = _vaultsList[i];
    }
    return _activeVaults;
  }

  function addVaultToList(address asset, address vault) external {
    uint256 vaultsCount = _vaultsCount;

    bool vaultAlreadyAdded = address(_vaults[asset]) != address(0);

    if (!vaultAlreadyAdded) {
      _vaults[asset] = IERC4626(vault);
      _vaultsList[vaultsCount] = vault;

      _vaultsCount = vaultsCount + 1;
    }
  }

  /**
   * @dev Returns the list of the active connectors
   **/
  function getConnectorsList() external view returns (address[] memory) {
    address[] memory _activeConnectors = new address[](_connectorsCount);

    for (uint256 i = 0; i < _connectorsCount; i++) {
      _activeConnectors[i] = _connectorsList[i];
    }
    return _activeConnectors;
  }

  /**
   * @dev Adds a new connector to the list of supported connectors.
   * @param connector The address of the connector to be added.
   */
  function addConnector(address connector) external onlyOwner {
    uint256 connectorsCount = _connectorsCount;

    require(_connectorsList[connectorsCount] == address(0), "connector already added");
    require(connector != address(0), "invalid address");

    _connectorsList[connectorsCount] = connector;
    _connectorsCount = connectorsCount + 1;

    emit ConnectorAdded(connector, connectorsCount + 1);
  }

  /**
   * @dev Removes a connector from the list of connectors
   * - make sure to update the frontend to remove and reorder the connector list
   * @param index The index of the connector to be removed
   */
  function removeConnector(uint256 index) external onlyOwner {
    uint256 connectorsCount = _connectorsCount;
    address connector = _connectorsList[index];

    require(index < connectorsCount, "index out of bounds");
    require(connector != address(0), "connector not found at index");

    // If it's not the last one, move the last one to this spot
    if (index != connectorsCount - 1) {
      _connectorsList[index] = _connectorsList[connectorsCount - 1];
    }

    // Delete the last one and reduce the count
    delete _connectorsList[connectorsCount - 1];
    _connectorsCount = connectorsCount - 1;

    emit ConnectorRemoved(connector, connectorsCount - 1);
  }

  function _supplyToSource(
    address _asset,
    uint256 _amount,
    address _user,
    address _connector
  ) internal returns (address, IERC4626) {
    address source = IConnector(_connector).getYieldSource(_asset);
    address underlying = IConnector(_connector).getUnderlyingAsset(_asset, source);
    // transfer the underlying asset from user to the connector contract
    IERC20(underlying).safeTransferFrom(_user, _connector, _amount);

    // deposit asset to the external yield source
    IConnector(_connector).deposit(underlying, _amount, address(this), source);

    return (underlying, _vaults[underlying]);
  }

  function _depositAndBorrow(
    address _collateralUnderlying,
    address _collateralAsset,
    uint256 _collateralAmount,
    address _debtAsset,
    uint256 _debtAmount,
    address _connector,
    address _caller
  ) internal {
    address collateralSource = IConnector(_connector).getYieldSource(_collateralAsset);
    address debtSource = IConnector(_connector).getYieldSource(_debtAsset);
    address debtUnderlying = IConnector(_connector).getUnderlyingAsset(_debtAsset, debtSource);

    IConnector(_connector).deposit(
      _collateralUnderlying,
      _collateralAmount,
      _connector,
      collateralSource
    );
    IConnector(_connector).borrow(debtUnderlying, _debtAmount, _caller, debtSource);
  }
}

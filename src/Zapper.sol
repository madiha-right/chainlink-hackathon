// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import { IZapper } from "./interfaces/IZapper.sol";
import { IConnector } from "./interfaces/IConnector.sol";

contract Zapper is IZapper, Ownable {
  using SafeERC20 for IERC20;

  // the number of yield sources supported
  uint256 private _connectorsCount;
  uint256 private _vaultsCount;

  // connector address => connector data
  mapping(address => ConnectorData) private _connectors;
  // asset => vault
  mapping(address => VaultData) private _vaults;

  // the list of the available connectors(which connects to sources), structured as a mapping for gas savings reasons
  mapping(uint256 => address) private _connectorsList;
  // the list of the available vaults
  mapping(uint256 => address) private _vaultsList;

  // Map of users address and their account (userAddress => userAccount)
  mapping(address => address) public accounts;

  constructor(address initialOwner) Ownable(initialOwner) { }

  // asset => user => balance
  mapping(address => mapping(address => uint256)) private _balances;

  function depositToVault(address asset, uint256 amount) external {
    VaultData memory vault = _vaults[asset];

    require(vault.addr != address(0), "vault not found");
    require(vault.isActive, "vault not active");

    IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

    if (IERC20(asset).allowance(address(this), vault.addr) < amount) {
      IERC20(asset).forceApprove(vault.addr, type(uint256).max);
    }

    IERC4626(vault.addr).deposit(amount, address(this));
  }

  function withdrawFromVault(address asset, uint256 shares) external {
    VaultData memory vault = _vaults[asset];

    require(vault.addr != address(0), "vault not found");
    require(vault.isActive, "vault not active");

    IERC20(vault.addr).safeTransferFrom(msg.sender, address(this), shares);

    uint256 withdrawnAmount = IERC4626(vault.addr).redeem(shares, address(this), address(this));

    IERC20(asset).safeTransfer(msg.sender, withdrawnAmount);
  }

  // need approval for the supply asset
  function zapDepositAndBorrow(
    address collateralAsset,
    uint256 collateralAmount,
    address collateralConnector,
    address debtAsset,
    uint256 debtAmount,
    address debtConnector
  ) external {
    ConnectorData memory supplyConnectorData = _connectors[collateralConnector];
    ConnectorData memory loanConnectorData = _connectors[debtConnector];

    if (!supplyConnectorData.isActive || !loanConnectorData.isActive) {
      revert InvalidConnector();
    }

    VaultData memory vault = _vaults[collateralAsset];

    if (vault.addr == address(0) || !vault.isActive) {
      revert InvalidVault();
    }

    _supplyToSource(collateralAsset, collateralAmount, msg.sender, collateralConnector);

    IERC4626(vault.addr).withdraw(collateralAmount, debtConnector, address(this));

    _depositAndBorrow(collateralAsset, collateralAmount, debtAsset, debtAmount, debtConnector, msg.sender);
  }

  /////////////////////////////////////////
  /////////////// SETTERS /////////////////
  /////////////////////////////////////////

  function initConnector(address connector) external onlyOwner {
    ConnectorData storage connectorData = _connectors[connector];
    uint256 connectorsCount = _connectorsCount;

    bool connectorAlreadyAdded = connectorData.id != 0 || _connectorsList[0] == connector;

    require(!connectorAlreadyAdded, "connector already added");

    connectorData.id = uint8(connectorsCount);
    connectorData.isActive = true;
    _connectorsList[connectorsCount] = connector;

    _connectorsCount = connectorsCount + 1;
    emit ConnectorInitialized(connector);
  }

  function initVault(address vault) external onlyOwner {
    address asset = IERC4626(vault).asset();
    VaultData storage vaultData = _vaults[asset];
    uint256 vaultsCount = _vaultsCount;

    bool vaultAlreadyAdded = vaultData.id != 0 || _vaultsList[0] == address(vault);

    require(!vaultAlreadyAdded, "vault already added");

    vaultData.id = uint8(vaultsCount);
    vaultData.isActive = true;
    vaultData.addr = address(vault);
    _vaultsList[vaultsCount] = address(vault);

    _vaultsCount = vaultsCount + 1;
    emit VaultInitialized(address(vault), asset);
  }

  function activateConnector(address connector) external onlyOwner {
    _connectors[connector].isActive = true;
    emit ConnectorActivated(connector);
  }

  function deactivateConnector(address connector) external onlyOwner {
    _connectors[connector].isActive = false;
    emit ConnectorDeactivated(connector);
  }

  function activateVault(address vault) external onlyOwner {
    address asset = IERC4626(vault).asset();
    _vaults[asset].isActive = true;
    emit VaultActivated(vault, asset);
  }

  function deactivateVault(address vault) external onlyOwner {
    address asset = IERC4626(vault).asset();
    _vaults[asset].isActive = false;
    emit VaultDeactivated(vault, asset);
  }

  /////////////////////////////////////////
  /////////////// GETTERS /////////////////
  /////////////////////////////////////////

  function getConnectorsList() external view returns (address[] memory) {
    uint256 connectorsListCount = _connectorsCount;
    uint256 droppedConnectorsCount = 0;
    address[] memory connectorsList = new address[](connectorsListCount);

    for (uint256 i = 0; i < connectorsListCount; i++) {
      if (_connectors[_connectorsList[i]].isActive) {
        connectorsList[i - droppedConnectorsCount] = _connectorsList[i];
      } else {
        droppedConnectorsCount++;
      }
    }

    // Reduces the length of the connectors array by `droppedConnectorsCount`
    assembly {
      mstore(connectorsList, sub(connectorsListCount, droppedConnectorsCount))
    }

    return connectorsList;
  }

  function getVaultsList() external view returns (address[] memory) {
    uint256 vaultsListCount = _vaultsCount;
    uint256 droppedVaultsCount = 0;
    address[] memory vaultsList = new address[](vaultsListCount);

    for (uint256 i = 0; i < vaultsListCount; i++) {
      if (_vaults[IERC4626(_vaultsList[i]).asset()].isActive) {
        vaultsList[i - droppedVaultsCount] = _vaultsList[i];
      } else {
        droppedVaultsCount++;
      }
    }

    // Reduces the length of the vaults array by `droppedVaultsCount`
    assembly {
      mstore(vaultsList, sub(vaultsListCount, droppedVaultsCount))
    }

    return vaultsList;
  }

  /////////////////////////////////////////
  //////// INTERNAL FUNCTIONS /////////////
  /////////////////////////////////////////

  function _supplyToSource(address asset, uint256 amount, address sender, address connector) internal {
    // transfer the underlying asset from sender to the connector contract
    IERC20(asset).safeTransferFrom(sender, connector, amount);

    // deposit collateral to the external yield source
    IConnector(connector).deposit(asset, amount, address(this));
  }

  function _depositAndBorrow(
    address collateralAsset,
    uint256 collateralAmount,
    address debtAsset,
    uint256 debtAmount,
    address connector,
    address sender
  ) internal {
    IConnector(connector).deposit(collateralAsset, collateralAmount, connector);
    IConnector(connector).borrow(debtAsset, debtAmount, sender);
  }
}

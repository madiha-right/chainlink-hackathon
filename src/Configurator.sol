// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { VersionedInitializable } from "../lib/upgradeability/VersionedInitializable.sol";

import { IRouter } from "./interfaces/IRouter.sol";
import { IConnectors } from "./interfaces/IConnectors.sol";
import { IVaults } from "./interfaces/IVaults.sol";
import { IACLManager } from "./interfaces/IACLManager.sol";
import { IConfigurator } from "./interfaces/IConfigurator.sol";
import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

import { Errors } from "./lib/Errors.sol";

/**
 * @title Configurator
 * @dev Implements the configuration methods for the protocol
 */
contract Configurator is VersionedInitializable, IConfigurator {
  /* ============ Constants ============ */

  uint256 public constant CONFIGURATOR_REVISION = 0x1;

  /* ============ State Variables ============ */

  IRouter internal _router;
  IConnectors internal _connectors;
  IVaults internal _vaults;
  IAddressesProvider internal _addressesProvider;

  /* ============ Modifiers ============ */

  /// @dev Only pool admin can call functions marked by this modifier.
  modifier onlyRouterAdmin() {
    _onlyRouterAdmin();
    _;
  }

  /// @dev Only connector admin can call functions marked by this modifier.
  modifier onlyConnectorAdmin() {
    _onlyConnectorAdmin();
    _;
  }

  /// @dev Only vault admin can call functions marked by this modifier.
  modifier onlyVaultAdmin() {
    _onlyVaultAdmin();
    _;
  }

  /* ============ Initializer ============ */

  function initialize(IAddressesProvider provider) public initializer {
    _addressesProvider = provider;
    _router = IRouter(_addressesProvider.getRouter());
    _connectors = IConnectors(_addressesProvider.getConnectors());
  }

  /* ============ External Functions ============ */

  /// @dev See {IConfigurator-setFee}.
  function setFee(uint256 fee) external onlyRouterAdmin {
    uint256 currentFee = _router.fee();
    _router.setFee(fee);
    emit ChangeRouterFee(currentFee, fee);
  }

  /// @dev See {IConfigurator-addConnectors}.
  function addConnectors(string[] calldata names, address[] calldata addresses) external onlyConnectorAdmin {
    _connectors.addConnectors(names, addresses);
  }

  /// @dev See {IConfigurator-updateConnectors}.
  function updateConnectors(string[] calldata names, address[] calldata addresses) external onlyConnectorAdmin {
    _connectors.updateConnectors(names, addresses);
  }

  /// @dev See {IConfigurator-removeConnectors}.
  function removeConnectors(string[] calldata names) external onlyConnectorAdmin {
    _connectors.removeConnectors(names);
  }

  /// @dev See {IConfigurator-addVaults}.
  function addVaults(address[] calldata assets, address[] calldata addresses) external onlyVaultAdmin {
    _vaults.addVaults(assets, addresses);
  }

  /// @dev See {IConfigurator-removeVaults}.
  function removeVaults(address[] calldata assets) external onlyVaultAdmin {
    _vaults.removeVaults(assets);
  }

  /* ============ Internal Functions ============ */

  function _onlyRouterAdmin() internal view {
    address aclManager = _addressesProvider.getACLManager();
    if (!IACLManager(aclManager).isRouterAdmin(msg.sender)) revert Errors.CallerNotRouterAdmin();
  }

  function _onlyConnectorAdmin() internal view {
    address aclManager = _addressesProvider.getACLManager();
    if (!IACLManager(aclManager).isConnectorAdmin(msg.sender)) revert Errors.CallerNotConnectorAdmin();
  }

  function _onlyVaultAdmin() internal view {
    address aclManager = _addressesProvider.getACLManager();
    if (!IACLManager(aclManager).isVaultAdmin(msg.sender)) revert Errors.CallerNotConnectorAdmin();
  }

  /**
   * @notice Returns the version of the Configurator contract.
   * @return The version is needed to update the proxy.
   */
  function getRevision() internal pure override returns (uint256) {
    return CONFIGURATOR_REVISION;
  }
}

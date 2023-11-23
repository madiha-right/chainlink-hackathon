// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

import { IACLManager } from "./interfaces/IACLManager.sol";
import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

import { Errors } from "./lib/Errors.sol";

/**
 * @title ACLManager
 * @notice Access Control List Manager. Main registry of system roles and permissions.
 */
contract ACLManager is AccessControl, IACLManager {
  /* ============ Constants ============ */

  bytes32 public constant ROUTER_ADMIN_ROLE = keccak256("ROUTER_ADMIN_ROLE");
  bytes32 public constant CONNECTOR_ADMIN_ROLE = keccak256("CONNECTOR_ADMIN_ROLE");
  bytes32 public constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");

  /* ============ Immutables ============ */

  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  /* ============ Constructor ============ */

  /**
   * @dev Constructor
   * @dev The ACL admin should be initialized at the addressesProvider beforehand
   * @param provider The address of the AddressesProvider
   */
  constructor(address provider) {
    ADDRESSES_PROVIDER = IAddressesProvider(provider);
    address aclAdmin = IAddressesProvider(provider).getACLAdmin();

    if (aclAdmin == address(0)) revert Errors.ACLAdminCannotBeZero();
    _grantRole(DEFAULT_ADMIN_ROLE, aclAdmin);
  }

  /* ============ External Functions ============ */

  function setRoleAdmin(bytes32 role, bytes32 adminRole) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _setRoleAdmin(role, adminRole);
  }

  function addConnectorAdmin(address admin) external override {
    grantRole(CONNECTOR_ADMIN_ROLE, admin);
  }

  function removeConnectorAdmin(address admin) external override {
    revokeRole(CONNECTOR_ADMIN_ROLE, admin);
  }

  function addVaultAdmin(address admin) external override {
    grantRole(VAULT_ADMIN_ROLE, admin);
  }

  function removeVaultAdmin(address admin) external override {
    revokeRole(VAULT_ADMIN_ROLE, admin);
  }

  function addRouterAdmin(address admin) external override {
    grantRole(ROUTER_ADMIN_ROLE, admin);
  }

  function removeRouterAdmin(address admin) external override {
    revokeRole(ROUTER_ADMIN_ROLE, admin);
  }

  function isConnectorAdmin(address admin) external view override returns (bool) {
    return hasRole(CONNECTOR_ADMIN_ROLE, admin);
  }

  function isVaultAdmin(address admin) external view override returns (bool) {
    return hasRole(VAULT_ADMIN_ROLE, admin);
  }

  function isRouterAdmin(address admin) external view override returns (bool) {
    return hasRole(ROUTER_ADMIN_ROLE, admin);
  }
}

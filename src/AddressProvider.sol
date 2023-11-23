// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { InitializableAdminUpgradeabilityProxy } from
  "@openzeppelin/contracts/proxy/upgradeability/InitializableAdminUpgradeabilityProxy.sol";

import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

/**
 * @title AddressesProvider
 * @notice Main registry of addresses part of or connected to the protocol
 * @dev Acts as factory of proxies, so with right to change its implementations
 */
contract AddressesProvider is Ownable, IAddressesProvider {
  /* ============ Constants ============ */

  // Main identifiers
  bytes32 private constant ROUTER = "ROUTER";
  bytes32 private constant ACCOUNT = "ACCOUNT";
  bytes32 private constant TREASURY = "TREASURY";
  bytes32 private constant ACL_ADMIN = "ACL_ADMIN";
  bytes32 private constant CONNECTORS = "CONNECTORS";
  bytes32 private constant VAULTS = "VAULTS";
  bytes32 private constant ACL_MANAGER = "ACL_MANAGER";
  bytes32 private constant CONFIGURATOR = "CONFIGURATOR";
  bytes32 private constant ACCOUNT_PROXY = "ACCOUNT_PROXY";

  /* ============ State Variables ============ */

  // Map of registered addresses (identifier => registeredAddress)
  mapping(bytes32 => address) private _addresses;

  /* ============ Constructor ============ */

  /**
   * @dev Constructor.
   * @param newOwner The owner address of this contract.
   */
  constructor(address newOwner) {
    transferOwnership(newOwner);
  }

  /* ============ External Functions ============ */

  /// @dev See {IAddressesProvider-setAddress}.
  function setAddress(bytes32 id, address newAddress) external override onlyOwner {
    address oldAddress = _addresses[id];
    _addresses[id] = _newAddress;
    emit AddressSet(id, oldAddress, newAddress);
  }

  /// @dev See {IAddressesProvider-setRouterImpl}.
  function setRouterImpl(address newRouterImpl) external override onlyOwner {
    address oldRouterImpl = _getProxyImplementation(ROUTER);
    _updateImpl(ROUTER, newRouterImpl);
    emit RouterUpdated(oldRouterImpl, newRouterImpl);
  }

  /// @dev See {IAddressesProvider-setConfiguratorImpl}.
  function setConfiguratorImpl(address newConfiguratorImpl) external override onlyOwner {
    address oldConfiguratorImpl = _getProxyImplementation(CONFIGURATOR);
    _updateImpl(CONFIGURATOR, newConfiguratorImpl);
    emit ConfiguratorUpdated(oldConfiguratorImpl, newConfiguratorImpl);
  }

  /// @dev See {IAddressesProvider-getRouter}.
  function getRouter() external view override returns (address) {
    return getAddress(ROUTER);
  }

  /// @dev See {IAddressesProvider-getConfigurator}.
  function getConfigurator() external view override returns (address) {
    return getAddress(CONFIGURATOR);
  }

  /// @dev See {IAddressesProvider-getACLAdmin}.
  function getACLAdmin() external view override returns (address) {
    return getAddress(ACL_ADMIN);
  }

  /// @dev See {IAddressesProvider-getACLManager}.
  function getACLManager() external view override returns (address) {
    return getAddress(ACL_MANAGER);
  }

  /// @dev See {IAddressesProvider-getConnectors}.
  function getConnectors() external view override returns (address) {
    return getAddress(CONNECTORS);
  }

  /// @dev See {IAddressesProvider-getVaults}.
  function getVaults() external view override returns (address) {
    return getAddress(VAULTS);
  }

  /// @dev See {IAddressesProvider-getTreasury}.
  function getTreasury() external view override returns (address) {
    return getAddress(TREASURY);
  }

  /// @dev See {IAddressesProvider-getAccount}.
  function getAccountImpl() external view override returns (address) {
    return getAddress(ACCOUNT);
  }

  /// @dev See {IAddressesProvider-getAccountProxy}.
  function getAccountProxy() external view override returns (address) {
    return getAddress(ACCOUNT_PROXY);
  }

  /* ============ Public Functions ============ */

  /// @dev See {IAddressesProvider-getAddress}.
  function getAddress(bytes32 id) public view override returns (address) {
    return _addresses[id];
  }

  /* ============ Internal Functions ============ */

  /**
   * @notice Internal function to update the implementation of a specific proxied component of the protocol.
   * @dev If there is no proxy registered with the given identifier, it creates the proxy setting `newAddress`
   *   as implementation and calls the initialize() function on the proxy
   * @dev If there is already a proxy registered, it just updates the implementation to `newAddress` and
   *   calls the initialize() function via upgradeToAndCall() in the proxy
   * @param id The id of the proxy to be updated
   * @param newAddress The address of the new implementation
   */
  function _updateImpl(bytes32 id, address newAddress) internal {
    address proxyAddress = _addresses[id];
    InitializableAdminUpgradeabilityProxy proxy;
    bytes memory params = abi.encodeWithSignature("initialize(address)", address(this));

    if (proxyAddress == address(0)) {
      proxy = new InitializableAdminUpgradeabilityProxy();
      _addresses[id] = proxyAddress = address(proxy);
      proxy.initialize(newAddress, address(this), params);
      emit ProxyCreated(id, proxyAddress, newAddress);
    } else {
      proxy = InitializableAdminUpgradeabilityProxy(payable(proxyAddress));
      proxy.upgradeToAndCall(newAddress, params);
    }
  }

  /**
   * @notice Returns the the implementation contract of the proxy contract by its identifier.
   * @dev It returns ZERO if there is no registered address with the given id
   * @dev It reverts if the registered address with the given id is not `InitializableAdminUpgradeabilityProxy`
   * @param id The id
   * @return The address of the implementation contract
   */
  function _getProxyImplementation(bytes32 id) internal returns (address) {
    address proxyAddress = _addresses[id];
    if (proxyAddress == address(0)) {
      return address(0);
    } else {
      address payable payableProxyAddress = payable(proxyAddress);
      return InitializableAdminUpgradeabilityProxy(payableProxyAddress).implementation();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAddressesProvider {
  /* ============ Events ============ */
  /**
   * @dev Emitted when a new non-proxied contract address is registered.
   * @param id The identifier of the contract
   * @param oldAddress The address of the old contract
   * @param newAddress The address of the new contract
   */
  event AddressSet(bytes32 indexed id, address indexed oldAddress, address indexed newAddress);

  /**
   * @dev Emitted when a new proxy is created.
   * @param id The identifier of the proxy
   * @param proxyAddress The address of the created proxy contract
   * @param implementationAddress The address of the implementation contract
   */
  event ProxyCreated(bytes32 indexed id, address indexed proxyAddress, address indexed implementationAddress);

  /**
   * @dev Emitted when the router is updated.
   * @param oldAddress The old address of the Router
   * @param newAddress The new address of the Router
   */
  event RouterUpdated(address indexed oldAddress, address indexed newAddress);

  /**
   * @dev Emitted when the router configurator is updated.
   * @param oldAddress The old address of the Router
   * @param newAddress The new address of the Router
   */
  event ConfiguratorUpdated(address indexed oldAddress, address indexed newAddress);

  /**
   * @dev Set contract address for the current id.
   * @param id Contract name in bytes32.
   * @param newAddress New contract address.
   */
  function setAddress(bytes32 id, address newAddress) external;

  /**
   * @notice Updates the implementation of the Router, or creates a proxy
   * setting the new `Router` implementation when the function is called for the first time.
   * @param newRouterImpl The new Router implementation
   */
  function setRouterImpl(address newRouterImpl) external;

  /**
   * @notice Updates the implementation of the Configurator, or creates a proxy
   * setting the new `Configurator` implementation when the function is called for the first time.
   * @param newConfiguratorImpl The new Configurator implementation
   */
  function setConfiguratorImpl(address newConfiguratorImpl) external;

  /**
   * @notice Returns the address of the Router proxy.
   * @return The Router proxy address
   */
  function getRouter() external view returns (address);

  /**
   * @notice Returns the address of the Router configurator proxy.
   * @return The Router configurator proxy address
   */
  function getConfigurator() external view returns (address);

  /**
   * @notice Returns the address of the ACL admin.
   * @return The address of the ACL admin
   */
  function getACLAdmin() external view returns (address);

  /**
   * @notice Returns the address of the ACL manager.
   * @return The address of the ACLManager
   */
  function getACLManager() external view returns (address);

  /**
   * @notice Returns the address of the Connectors proxy.
   * @return The Connectors proxy address
   */
  function getConnectors() external view returns (address);

  /**
   * @notice Returns the address of the Vaults proxy.
   * @return The Vaults proxy address
   */
  function getVaults() external view returns (address);

  /**
   * @notice Returns the address of the Treasury proxy.
   * @return The Treasury proxy address
   */
  function getTreasury() external view returns (address);

  /**
   * @notice Returns the address of the Account implementation.
   * @return The Account implementation address
   */
  function getAccountImpl() external view returns (address);

  /**
   * @notice Returns the address of the Account proxy.
   * @return The Account proxy address
   */
  function getAccountProxy() external view returns (address);

  /**
   * @param id The key to obtain the address.
   * @return Returns the contract address.
   */
  function getAddress(bytes32 id) external view returns (address);
}

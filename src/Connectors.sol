// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IConnector } from "./interfaces/IConnector.sol";
import { IConnectors } from "./interfaces/IConnectors.sol";
import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

import { Errors } from "./lib/Errors.sol";

/**
 * @title Connectors
 * @notice Contract to manage and store auxiliary contracts to work with the necessary protocols
 */
contract Connectors is IConnectors {
  /* ============ Immutables ============ */
  // The contract by which all other contact addresses are obtained.
  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  /* ============ State Variables ============ */

  // Enabled Connectors(Connector name => address).
  mapping(string => address) private _connectors;

  /* ============ Modifiers ============ */

  /**
   * @dev Only pool configurator can call functions marked by this modifier.
   */
  modifier onlyConfigurator() {
    if (ADDRESSES_PROVIDER.getConfigurator() != msg.sender) revert Errors.CallerNotConfigurator();
    _;
  }

  /* ============ Constructor ============ */

  /**
   * @dev Constructor.
   * @param provider The address of the AddressesProvider contract
   */
  constructor(address provider) {
    ADDRESSES_PROVIDER = IAddressesProvider(provider);
  }

  /* ============ External Functions ============ */

  /// @dev See {IConnectors-addConnectors}.
  function addConnectors(string[] calldata names, address[] calldata connectors) external override onlyConfigurator {
    if (names.length != connectors.length) revert Errors.InvalidConnectorsLength();

    for (uint256 i = 0; i < connectors.length; i++) {
      string memory name = names[i];
      address connector = connectors[i];

      if (_connectors[name] != address(0)) revert Errors.ConnectorAlreadyExist();
      if (connector == address(0)) revert Errors.InvalidConnectorAddress();

      _connectors[name] = connector;

      emit ConnectorAdded(name, connector);
    }
  }

  /// @dev See {IConnectors-updateConnectors}.
  function updateConnectors(string[] calldata names, address[] calldata connectors) external override onlyConfigurator {
    if (names.length != connectors.length) revert Errors.InvalidConnectorsLength();

    for (uint256 i = 0; i < connectors.length; i++) {
      string memory name = names[i];
      address connector = connectors[i];
      address oldConnector = _connectors[name];

      if (_connectors[name] != address(0)) revert Errors.ConnectorAlreadyExist();
      if (connector == address(0)) revert Errors.InvalidConnectorAddress();

      _connectors[name] = connector;

      emit ConnectorUpdated(name, oldConnector, connector);
    }
  }

  /// @dev See {IConnectors-removeConnectors}.
  function removeConnectors(string[] calldata names) external override onlyConfigurator {
    for (uint256 i = 0; i < names.length; i++) {
      string memory name = names[i];
      address connector = _connectors[name];

      if (connector == address(0)) revert Errors.ConnectorDoesNotExist();

      emit ConnectorRemoved(name, connector);
      delete _connectors[name];
    }
  }

  /// @dev See {IConnectors-isConnector}.
  function isConnector(string calldata name) external view returns (bool, address) {
    bool isOk = true;
    address connector = _connectors[name];

    if (connector == address(0)) {
      isOk = false;
    }

    return (isOk, connector);
  }
}

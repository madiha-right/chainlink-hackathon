// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IConnectors {
  /* ============ Events ============ */
  /**
   * @dev Emitted when new connector added.
   * @param name Connector name.
   * @param connector Connector contract address.
   */
  event ConnectorAdded(string name, address indexed connector);

  /**
   * @dev Emitted when the router is updated.
   * @param name Connector name.
   * @param oldConnector Old connector contract address.
   * @param newConnector New connector contract address.
   */
  event ConnectorUpdated(string name, address indexed oldConnector, address indexed newConnector);

  /**
   * @dev Emitted when connecter will be removed.
   * @param name Connector name.
   * @param connector Connector contract address.
   */
  event ConnectorRemoved(string name, address indexed connector);

  /**
   * @dev Add Connectors
   * @param names Array of Connector Names.
   * @param connectors Array of Connector Address.
   */
  function addConnectors(string[] calldata names, address[] calldata connectors) external;

  /**
   * @dev Update Connectors
   * @param names Array of Connector Names.
   * @param connectors Array of Connector Address.
   */
  function updateConnectors(string[] calldata names, address[] calldata connectors) external;

  /**
   * @dev Remove Connectors
   * @param names Array of Connector Names.
   */
  function removeConnectors(string[] calldata names) external;

  /**
   * @dev Check if Connector addresses are enabled.
   * @param name Connector Name.
   */
  function isConnector(string calldata name) external view returns (bool isOk, address _connector);
}

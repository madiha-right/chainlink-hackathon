// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IConfigurator {
  /* ============ Events ============ */

  /**
   * @dev Emitted when set new router fee.
   * @param oldFee The old fee, expressed in bps
   * @param newFee The new fee, expressed in bps
   */
  event ChangeRouterFee(uint256 oldFee, uint256 newFee);

  /**
   * @notice Set a new fee to the router contract.
   * @param fee The new amount
   */
  function setFee(uint256 fee) external;

  /**
   * @dev Add Connectors to the connectors contract
   * @param names Array of Connector Names.
   * @param addresses Array of Connector Address.
   */
  function addConnectors(string[] calldata names, address[] calldata addresses) external;

  /**
   * @dev Update Connectors on the connectors contract
   * @param names Array of Connector Names.
   * @param addresses Array of Connector Address.
   */
  function updateConnectors(string[] calldata names, address[] calldata addresses) external;

  /**
   * @dev Remove Connectors on the connectors contract
   * @param names Array of Connector Names.
   */
  function removeConnectors(string[] calldata names) external;

  /**
   * @dev Add Vaults to the vaults contract
   * @param assets Array of underlying asset addresses of Vaults.
   * @param addresses Array of Vault Address.
   */
  function addVaults(address[] calldata assets, address[] calldata addresses) external;

  /**
   * @dev Remove Vaults on the vaults contract
   * @param assets Array of underlying assets addresses of Vaults.
   */
  function removeVaults(address[] calldata assets) external;
}

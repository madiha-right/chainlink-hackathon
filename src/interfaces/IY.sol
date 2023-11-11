// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;
pragma abicoder v2;

import { ILendingPool } from "./aave-v2/ILendingPool.sol";

interface IY {
  /**
   * @dev Emitted when an external source (yield source) is used to deposit assets.
   * @param asset The address of the asset being deposited.
   * @param user The address of the user who made the deposit.
   * @param amount The amount of the asset deposited.
   * @param yieldSource The address of the external yield source where the deposit was made.
   **/
  event ExternalDeposit(
    address indexed asset,
    address indexed user,
    uint256 amount,
    address indexed yieldSource
  );

  /**
   * @dev Emitted when an external source (yield source) is used to withdraw assets.
   * @param asset The address of the asset being withdrawn.
   * @param user The address of the user who made the withdraw.
   * @param to The address to which the asset is withdrawn.
   * @param amount The amount of the asset withdrawn.
   * @param yieldSource The address of the external yield source from where the withdrawal was made.
   **/
  event ExternalWithdraw(
    address indexed asset,
    address indexed user,
    address to,
    uint256 amount,
    address indexed yieldSource
  );

  /**
   * @dev Emitted when a new connector is added.
   * @param connector The address of the newly added connector.
   * @param connectorsCount The total number of active connectors after this addition.
   **/
  event ConnectorAdded(address indexed connector, uint256 connectorsCount);

  /**
   * @dev Emitted when a connector is removed.
   * @param connector The address of the removed connector.
   * @param connectorsCount The total number of active connectors after this removal.
   **/
  event ConnectorRemoved(address indexed connector, uint256 connectorsCount);

  function depositToVault(address asset, uint256 amount) external;

  function withdrawFromVault(address asset, uint256 amount) external;

  function zapDepositAndBorrow(
    address supplyAsset,
    address collateralAsset,
    uint256 collateralAmount,
    uint256 collateralConnectorIdx,
    address debtAsset,
    uint256 debtAmount,
    uint256 debtConnectorIdx
  ) external;

  function balanceOf(address asset, address owner) external view returns (uint256);

  function getVaultsList() external view returns (address[] memory);

  function addVaultToList(address asset, address vault) external;

  /**
   * @dev Returns the list of the active connectors
   **/
  function getConnectorsList() external view returns (address[] memory);

  /**
   * @dev Adds a new connector to the list of supported connectors.
   * @param connector The address of the connector to be added.
   */
  function addConnector(address connector) external;

  /**
   * @dev Removes a connector from the list of connectors
   * - make sure to update the frontend to remove and reorder the connector list
   * @param index The index of the connector to be removed
   */
  function removeConnector(uint256 index) external;
}

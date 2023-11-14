// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.20;

import { ILendingPool } from "./aave-v2/ILendingPool.sol";

interface IZapper {
  error InvalidConnector();
  error InvalidVault();

  struct ConnectorData {
    uint8 id;
    bool isActive;
  }

  struct VaultData {
    uint8 id;
    bool isActive;
    address addr;
  }

  /**
   * @dev Emitted when an external source (yield source) is used to deposit assets.
   * @param asset The address of the asset being deposited.
   * @param user The address of the user who made the deposit.
   * @param amount The amount of the asset deposited.
   * @param yieldSource The address of the external yield source where the deposit was made.
   */
  event ExternalDeposit(address indexed asset, address indexed user, uint256 amount, address indexed yieldSource);

  /**
   * @dev Emitted when an external source (yield source) is used to withdraw assets.
   * @param asset The address of the asset being withdrawn.
   * @param user The address of the user who made the withdraw.
   * @param to The address to which the asset is withdrawn.
   * @param amount The amount of the asset withdrawn.
   * @param yieldSource The address of the external yield source from where the withdrawal was made.
   */
  event ExternalWithdraw(
    address indexed asset, address indexed user, address to, uint256 amount, address indexed yieldSource
  );

  /**
   * @dev Emitted when a connector is initialized.
   * @param connector The address of the initialized connector.
   */
  event ConnectorInitialized(address indexed connector);

  /**
   * @dev Emitted when a vault is initialized.
   * @param vault The address of the initialized vault.
   * @param underlyingAsset The address of the underlying asset
   */
  event VaultInitialized(address indexed vault, address indexed underlyingAsset);

  /**
   * @dev Emitted when a connector is activated.
   * @param connector The address of the activated connector.
   *
   */
  event ConnectorActivated(address indexed connector);

  /**
   * @dev Emitted when a vault is activated.
   * @param vault The address of the activated vault.
   * @param underlyingAsset The address of the underlying asset
   *
   */
  event VaultActivated(address indexed vault, address indexed underlyingAsset);

  /**
   * @dev Emitted when a connector is deactivated.
   * @param connector The address of the deactivated connector.
   */
  event ConnectorDeactivated(address indexed connector);

  /**
   * @dev Emitted when a vault is deactivated.
   * @param vault The address of the deactivated vault.
   * @param underlyingAsset The address of the underlying asset
   */
  event VaultDeactivated(address indexed vault, address indexed underlyingAsset);

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

  /**
   * @dev Initilize a new connector. Add connector to the list of supported connectors.
   * @param connector The address of the connector to be added.
   */
  function initConnector(address connector) external;

  /**
   * @dev Activates a connector.
   * @param connector The address of the connector to be deactivated.
   */
  function activateConnector(address connector) external;

  /**
   * @dev Deactivates a connector.
   * @param connector The address of the connector to be deactivated.
   */
  function deactivateConnector(address connector) external;

  /**
   * @dev Initilize a new vault. Add vault to the list of supported vaults.
   * @param vault The address of the vault to be added.
   */
  function initVault(address vault) external;

  /**
   * @dev Activates a vault.
   * @param vault The address of the vault to be activated.
   */
  function activateVault(address vault) external;

  /**
   * @dev Deactivates a vault.
   * @param vault The address of the vault to be deactivated.
   */
  function deactivateVault(address vault) external;

  /**
   * @dev Returns the list of the active connectors.
   */
  function getConnectorsList() external view returns (address[] memory);

  /**
   * @dev Returns the list of the active vaults.
   */
  function getVaultsList() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVaults {
  /* ============ Events ============ */
  /**
   * @dev Emitted when new Vault added.
   * @param asset underlying asset address.
   * @param vault Vault contract address.
   */
  event VaultAdded(address indexed asset, address indexed vault);

  /**
   * @dev Emitted when Vault will be removed.
   * @param asset underlying asset address.
   * @param vault Vault contract address.
   */
  event VaultRemoved(address indexed asset, address indexed vault);

  function vaults(address asset) external view returns (address);

  /**
   * @dev Add Vaults
   * @param assets Array of asset addresses.
   * @param vaults Array of vault address.
   */
  function addVaults(address[] calldata assets, address[] calldata vaults) external;

  /**
   * @dev Remove Vaults
   * @param assets Array of underlying assets of Vaults.
   */
  function removeVaults(address[] calldata assets) external;

  /**
   * @dev Check if asset address is enabled as vault.
   * @param asset address of the underlying asset.
   */
  function hasVault(address asset) external view returns (bool isOk, address vault);
}

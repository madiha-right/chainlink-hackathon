// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { console } from "forge-std/Console.sol";

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

import { IConnector } from "./interfaces/IConnector.sol";
import { IVaults } from "./interfaces/IVaults.sol";
import { IAddressesProvider } from "./interfaces/IAddressesProvider.sol";

import { Errors } from "./lib/Errors.sol";

/**
 * @title Vaults
 * @notice Contract to manage and store auxiliary contracts to work with the necessary protocols
 */
contract Vaults is IVaults {
  /* ============ Immutables ============ */
  // The contract by which all other contact addresses are obtained.
  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  /* ============ State Variables ============ */

  // Enabled Vaults(asset address => vault address).
  mapping(address => address) public vaults;

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

  /// @dev See {IVaults-addVaults}.
  function addVaults(address[] calldata _vaults) external onlyConfigurator {
    for (uint256 i = 0; i < _vaults.length; i++) {
      address vault = _vaults[i];

      if (vault == address(0)) revert Errors.InvalidVaultAddress();

      address asset = i == 0 ? 0xf97b6C636167B529B6f1D729Bd9bC0e2Bd491848 : 0x676bD5B5d0955925aeCe653C50426940c58036c8;

      if (vaults[asset] != address(0)) revert Errors.VaultAlreadyExist();

      vaults[asset] = vault;

      emit VaultAdded(asset, vault);
    }
  }
  // /// @dev See {IVaults-addVaults}.
  // function addVaults(address[] calldata _vaults) external onlyConfigurator {
  //   for (uint256 i = 0; i < _vaults.length; i++) {
  //     address vault = _vaults[i];

  //     if (vault == address(0)) revert Errors.InvalidVaultAddress();

  //     address asset = IERC4626(vault).asset();

  //     if (vaults[asset] != address(0)) revert Errors.VaultAlreadyExist();

  //     vaults[asset] = vault;

  //     emit VaultAdded(asset, vault);
  //   }
  // }

  /// @dev See {IVaults-removeVaults}.
  function removeVaults(address[] calldata assets) external onlyConfigurator {
    for (uint256 i = 0; i < assets.length; i++) {
      address asset = assets[i];
      address vault = vaults[asset];

      if (vault == address(0)) revert Errors.VaultDoesNotExist();

      emit VaultRemoved(asset, vault);
      delete vaults[asset];
    }
  }

  /// @dev See {IVaults-hasVault}.
  function hasVault(address asset) external view returns (bool, address) {
    bool isOk = true;
    address vault = vaults[asset];

    if (vault == address(0)) {
      isOk = false;
    }

    return (isOk, vault);
  }
}

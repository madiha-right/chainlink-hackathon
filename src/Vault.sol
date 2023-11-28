// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Vault
 */
contract Vault is ERC4626 {
  /* ============ Constructor ============ */

  /**
   * @dev Constructor.
   * @param asset The address of the underlying asset.
   * @param name The name of the vault token.
   * @param symbol The symbol of the vault token.
   */
  constructor(IERC20 asset, string memory name, string memory symbol) ERC4626(asset) ERC20(name, symbol) { }
}

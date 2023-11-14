// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IZapper } from "./IZapper.sol";

interface IVault is IERC4626 {
  /** @dev See {IERC4626-deposit}. */
  function deposit(uint256 amount, address receiver) external override returns (uint256);

  /** @dev See {IERC4626-mint}. */
  function mint(uint256 shares, address receiver) external override returns (uint256);

  /** @dev See {IERC4626-withdraw}. */
  function withdraw(
    uint256 amount,
    address receiver,
    address owner
  ) external override returns (uint256);

  /** @dev See {IERC4626-redeem}. */
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) external override returns (uint256);
}

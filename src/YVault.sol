// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IYVault } from "./interfaces/IYVault.sol";

contract YVault is IYVault, ERC4626 {
  address private immutable _Y;

  constructor(
    IERC20 asset,
    string memory name,
    string memory symbol,
    address y
  ) ERC4626(asset) ERC20(name, symbol) {
    _Y = y;
  }

  /** @dev See {IERC4626-deposit}. */
  function deposit(
    uint256 amount,
    address receiver
  ) public override(ERC4626, IYVault) returns (uint256) {
    return super.deposit(amount, receiver);
  }

  /** @dev See {IERC4626-mint}. */
  function mint(
    uint256 shares,
    address receiver
  ) public override(ERC4626, IYVault) returns (uint256) {
    return super.mint(shares, receiver);
  }

  /** @dev See {IERC4626-withdraw}. */
  function withdraw(
    uint256 amount,
    address receiver,
    address owner
  ) public override(ERC4626, IYVault) returns (uint256) {
    return super.withdraw(amount, receiver, owner);
  }

  /** @dev See {IERC4626-redeem}. */
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) public override(ERC4626, IYVault) returns (uint256) {
    return super.redeem(shares, receiver, owner);
  }

  function getY() external view returns (address) {
    return _Y;
  }
}

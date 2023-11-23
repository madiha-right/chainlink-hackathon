// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IConnector } from "../interfaces/IConnector.sol";

/**
 * @title BaseConnector
 * @dev This contract facilitates interactions with sources for deposit, withdrawal and borrowing.
 * 			It uses overridable internal functions to prevent missing onlyOwner modifier on the functions.
 */
abstract contract BaseConnector is IConnector, Ownable {
  constructor(address initialOwner) Ownable(initialOwner) { }
  // TODO: add events

  function deposit(address asset, uint256 amount, address onBehalfOf) external onlyOwner returns (uint256) {
    return _deposit(asset, amount, onBehalfOf);
  }

  function borrow(address asset, uint256 amount, address onBehalfOf) external onlyOwner {
    _borrow(asset, amount, onBehalfOf);
  }

  function withdraw(address asset, uint256 amount, address to) external onlyOwner {
    _withdraw(asset, amount, to);
  }

  function getYieldBearingAsset(address asset) external view virtual returns (address) { }

  function _deposit(address asset, uint256 amount, address onBehalfOf) internal virtual returns (uint256) { }

  function _borrow(address asset, uint256 amount, address onBehalfOf) internal virtual { }

  function _withdraw(address asset, uint256 amount, address to) internal virtual { }
}

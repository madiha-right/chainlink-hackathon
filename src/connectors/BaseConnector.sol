// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IConnector } from "../interfaces/IConnector.sol";

abstract contract BaseConnector is IConnector, Ownable {
  constructor(address initialOwner) Ownable(initialOwner) { }

  function deposit(address asset, uint256 amount, address onBehalfOf) external virtual onlyOwner { }

  function borrow(address asset, uint256 amount, address onBehalfOf) external virtual onlyOwner { }

  function withdraw(address asset, uint256 amount, address to, address yieldSource) external virtual onlyOwner { }

  function getYieldBearingAsset(address asset) external view virtual returns (address) { }
}

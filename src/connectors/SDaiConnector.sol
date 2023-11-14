// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IZapper } from "../interfaces/IZapper.sol";
import { IConnector } from "../interfaces/IConnector.sol";
import { BaseConnector } from "./BaseConnector.sol";

/**
 * @title SDAIConnector
 * @dev This contract facilitates interactions with SDai for deposit, withdrawal
 */
contract SDAIConnector is BaseConnector {
  using SafeERC20 for IERC20;

  address public immutable SDAI;

  constructor(address initialOwner, address sDAI) BaseConnector(initialOwner) {
    SDAI = sDAI;
  }

  /**
   * @dev See {IConnector-deposit}.
   */
  function deposit(address asset, uint256 amount, address onBehalfOf) external override {
    // approve underlying asset to the source
    if (IERC20(asset).allowance(address(this), SDAI) == 0) {
      IERC20(asset).forceApprove(SDAI, type(uint256).max);
    }

    IERC4626(SDAI).deposit(amount, onBehalfOf);
  }

  /**
   * @dev See {IConnector-borrow}.
   */
  function borrow(address asset, uint256 amount, address onBehalfOf) external override {
    revert Forbidden();
  }

  /**
   * @dev See {IConnector-withdraw}.
   */
  function withdraw(address asset, uint256 amount, address to, address yieldSource) external override {
    IERC4626(SDAI).withdraw(amount, to, to);
  }

  /**
   * @dev See {IConnector-getYieldSource}.
   */
  function getYieldBearingAsset(address asset) external view override returns (address) {
    return SDAI;
  }
}

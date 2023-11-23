// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IConnector } from "../interfaces/IConnector.sol";
import { BaseConnector } from "./BaseConnector.sol";

/**
 * @title SDAIConnector
 * @dev This contract facilitates interactions with SDai for deposit, withdrawal
 */
contract SDAIConnector is BaseConnector {
  using SafeERC20 for IERC20;

  address public constant SDAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;

  constructor(address initialOwner) BaseConnector(initialOwner) { }

  /**
   * @dev See {IConnector-getYieldSource}.
   */
  function getYieldBearingAsset(address asset) external view override returns (address) {
    return SDAI;
  }

  /**
   * @dev See {IConnector-deposit}.
   */
  function _deposit(address asset, uint256 amount, address onBehalfOf) internal override returns (uint256) {
    // approve underlying asset to the source
    if (IERC20(asset).allowance(address(this), SDAI) == 0) {
      IERC20(asset).forceApprove(SDAI, type(uint256).max);
    }

    return IERC4626(SDAI).deposit(amount, onBehalfOf);
  }

  /**
   * @dev sDAI does not support borrowing.
   */
  function _borrow(address asset, uint256 amount, address onBehalfOf) internal override {
    revert Forbidden();
  }

  /**
   * @dev See {IConnector-withdraw}.
   * @param amount The amount of shares to withdraw
   */
  function _withdraw(address asset, uint256 amount, address to) internal override {
    IERC20(SDAI).transferFrom(msg.sender, address(this), amount);

    if (IERC20(SDAI).allowance(address(this), SDAI) < amount) {
      IERC20(SDAI).forceApprove(SDAI, type(uint256).max);
    }

    IERC4626(SDAI).redeem(amount, to, address(this));
  }
}

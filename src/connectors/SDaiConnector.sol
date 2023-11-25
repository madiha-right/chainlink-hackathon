// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ISDAIConnector } from "../interfaces/connectors/ISDAIConnector.sol";

import { Errors } from "../lib/Errors.sol";

contract SDAIConnector {
  using SafeERC20 for IERC20;

  /* ============ Constants ============ */

  address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address internal constant SDAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;

  /**
   * @dev Connector name
   */
  string public constant NAME = "sDAI";

  /* ============ External Functions ============ */

  /// @dev See {ISDAIConnector-deposit}.
  function deposit(uint256 amount) external {
    amount = amount == type(uint256).max ? IERC20(DAI).balanceOf(address(this)) : amount;
    IERC20(DAI).forceApprove(SDAI, amount);

    IERC4626(SDAI).deposit(amount, address(this));
  }

  /// @dev See {ISDAIConnector-redeem}.
  function redeem(uint256 shares) external {
    IERC4626(SDAI).redeem(shares, address(this), address(this));
  }

  function getDepositBalance(address account) external view returns (uint256) {
    return IERC4626(SDAI).convertToAssets(IERC4626(SDAI).balanceOf(account));
  }

  function getShares(address account) external view returns (uint256) {
    return IERC4626(SDAI).balanceOf(account);
  }
}

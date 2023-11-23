// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISDAIConnector {
  function NAME() external returns (string memory);

  /**
   * @dev Deposit DAI.
   * @notice Deposit DAI to sDAI vault for generating yield.
   * @param amount The amount of the token to deposit. (For max: `type(uint).max`)
   */
  function deposit(uint256 amount) external;

  /**
   * @dev Withdraw DAI.
   * @notice Withdraw deposited DAI from sDAI vault.
   * @param amount The amount of the sDAI shares to withdraw DAI. (For max: `type(uint).max`)
   */
  function redeem(address shares, uint256 amount) external;
}

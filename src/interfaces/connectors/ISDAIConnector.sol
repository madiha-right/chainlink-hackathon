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
   * @dev Redeem DAI.
   * @notice Redeem deposited DAI from sDAI vault.
   */
  function redeem(uint256 shares) external;

  function getDepositBalance(address account) external view returns (uint256);

  function getShares(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAaveV2Connector {
  function NAME() external returns (string memory);

  /**
   * @dev Deposit ERC20_Token.
   * @notice Deposit a token to Aave v2 for lending / collaterization.
   * @param token The address of the token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to deposit. (For max: `type(uint).max`)
   */
  function deposit(address token, uint256 amount) external;

  /**
   * @dev Withdraw ERC20_Token.
   * @notice Withdraw deposited token from Aave v2
   * @param token The address of the token to withdraw.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to withdraw. (For max: `type(uint).max`)
   */
  function withdraw(address token, uint256 amount) external;

  /**
   * @dev Borrow ERC20_Token.
   * @notice Borrow a token using Aave v2
   * @param token The address of the token to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to borrow.
   * @param rateMode The type of borrow debt. (For Stable: 1, Variable: 2)
   */
  function borrow(address token, uint256 amount, uint256 rateMode) external;

  /**
   * @dev Payback borrowed ERC20_Token.
   * @notice Payback debt owed.
   * @param token The address of the token to payback.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to payback. (For max: `type(uint).max`)
   * @param rateMode The type of debt paying back. (For Stable: 1, Variable: 2)
   */
  function payback(address token, uint256 amount, uint256 rateMode) external;

  /**
   * @dev Get total debt balance & fee for an asset
   * @param token token address of the debt.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param user Address whose balance we get.
   * @param rateMode Borrow rate mode (Stable = 1, Variable = 2)
   */
  function getPaybackBalance(address token, address user, uint256 rateMode) external view returns (uint256);

  /**
   * @dev Get total collateral balance for an asset
   * @param token token address of the collateral.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param user Address whose balance we get.
   */
  function getCollateralBalance(address token, address user) external view returns (uint256 balance);
}

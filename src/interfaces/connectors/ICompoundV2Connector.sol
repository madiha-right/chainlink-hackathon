// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { CErc20Interface } from "../external/compound-v2/CTokenInterfaces.sol";

interface ICompoundV2Connector {
  function NAME() external returns (string memory);

  /**
   * @dev Deposit ERC20_Token using the Mapping.
   * @notice Deposit a token to Compound for lending / collaterization.
   * @param token The address of the token to deposit. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to deposit. (For max: `type(uint).max`)
   */
  function deposit(address token, uint256 amount) external;

  /**
   * @dev Withdraw ERC20_Token.
   * @notice Withdraw deposited token from Compound
   * @param token The address of the token to withdraw. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to withdraw. (For max: `type(uint).max`)
   */
  function withdraw(address token, uint256 amount) external;

  /**
   * @dev Borrow ERC20_Token.
   * @notice Borrow a token using Compound
   * @param token The address of the token to borrow. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to borrow.
   */
  function borrow(address token, uint256 amount) external;

  /**
   * @dev Payback borrowed ETH/ERC20_Token.
   * @notice Payback debt owed.
   * @param token The address of the token to payback. (For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param amount The amount of the token to payback. (For max: `type(uint).max`)
   */
  function payback(address token, uint256 amount) external;

  /**
   * @dev Get total debt balance & fee for an asset
   * @param token Token address of the debt.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param user Address whose balance we get.
   */
  function borrowBalanceOf(address token, address user) external returns (uint256);

  /**
   * @dev Get total collateral balance for an asset
   * @param token Token address of the collateral.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   * @param user Address whose balance we get.
   */
  function collateralBalanceOf(address token, address user) external returns (uint256);

  /**
   * @dev Mapping base token to cToken
   * @param token Base token address.
   */
  function getCToken(address token) external pure returns (CErc20Interface);
}

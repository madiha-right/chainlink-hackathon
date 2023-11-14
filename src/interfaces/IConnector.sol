// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IConnector {
  error Forbidden();

  /**
   * @dev Deposits an `amount` of underlying asset into the yield source, receiving in return overlying yield source token.
   * - E.g. Y deposits 100 USDC to the aave v2 pool and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens representing the deposit
   */
  function deposit(address asset, uint256 amount, address onBehalfOf) external;

  /**
   * @dev Borrow an `amount` of underlying asset from the yield source, receiving in return overlying debt source token.
   * - E.g. Y borrows 100 USDC from the aave v2 pool and gets in return 100 debt USDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens representing the deposit
   */
  function borrow(address asset, uint256 amount, address onBehalfOf) external;

  /**
   * @dev Withdraws an `amount` of underlying asset from the yield source, burning the equivalent yield bearing token owned
   * E.g. Y has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
   * @param to Address that will receive the underlying, same as msg.sender if the user
   *   wants to receive it on his own wallet, or a different address if the beneficiary is a
   *   different wallet
   * @param yieldSource The address of the yield source. e.g. aave v2 pool, compound v2 cToken
   */
  function withdraw(address asset, uint256 amount, address to, address yieldSource) external;

  function getYieldBearingAsset(address asset) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { DataTypes } from "../lib/DataTypes.sol";

import { IAddressesProvider } from "./IAddressesProvider.sol";

interface IAccount {
  /* ============ Events ============ */

  /**
   * @dev Emitted when the tokens is claimed.
   * @param token The address of the token to withdraw.
   * @param amount The amount of the token to withdraw.
   */
  event ClaimedTokens(address token, address owner, uint256 amount);

  /**
   * @dev Emitted when the account take falshlaon.
   * @param token Flashloan token.
   * @param amount Flashloan amount.
   * @param fee Flashloan fee.
   */
  event Flashloan(address indexed token, uint256 amount, uint256 fee);

  /**
   * @dev initialize.
   * @param user Owner account address.
   * @param provider The address of the AddressesProvider contract.
   */
  function initialize(address user, IAddressesProvider provider) external;

  /**
   * @dev Takes a loan, calls `openPositionCallback` inside the loan, and transfers the commission.
   * - Swap poisition debt token to collateral token.
   * - Deposit collateral token to the lending protocol.
   * - Borrow debt token to repay flashloan.
   * @param position The structure of the current position.
   * @param data Calldata for the openPositionCallback.
   *  	_targetNames The connector name that will be called are.
   *  	_datas Calldata needed to work with the connector `_datas and _targetNames must be with the same index`.
   *  	_customDatas Additional parameters for future use.
   */
  function openPosition(DataTypes.Position memory position, bytes calldata data) external;

  /**
   * @dev Takes a loan, calls `closePositionCallback` inside the loan.
   * - Repay debt token to the lending protocol.
   * - Withdraw collateral token.
   * - Swap poisition collateral token to debt token.
   * @param key The key to obtain the current position.
   * @param data Calldata for the openPositionCallback.
   * 		_targetNames The connector name that will be called are.
   * 		_datas Calldata needed to work with the connector `_datas and _targetNames must be with the same index`.
   * 		_customDatas Additional parameters for future use.
   */
  function closePosition(bytes32 key, bytes calldata data) external;

  /**
   * @dev Called by the router which is called by the ccip contract to open a loan position.
   * - Deposit collateral token to the lending protocol.
   * - Borrow debt token from the lending protocol.
   * @param targetNames The connector name that will be called are.
   * @param datas Calldata needed to work with the connector `_datas and _targetNames must be with the same index`.
   */
  function openLoanPosition(string[] memory targetNames, bytes[] memory datas) external;

  /**
   * @dev Owner account claim tokens.
   * @param token The address of the token to withdraw.
   * @param amount The amount of the token to withdraw.
   */
  function claimTokens(address token, uint256 amount) external;
}

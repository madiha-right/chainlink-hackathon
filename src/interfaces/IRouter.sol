// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { DataTypes } from "../lib/DataTypes.sol";

interface IRouter {
  /* ============ Enums ============ */

  enum PositionType {
    OPEN,
    CLOSE
  }

  /* ============ Events ============ */

  /**
   * @dev Emitted when the account will be created.
   * @param account The address of the Account contract.
   * @param owner The address of the owner account.
   */
  event AccountCreated(address indexed account, address indexed owner);

  /**
   * @dev Emitted when the sender swap tokens.
   * @param sender Address who create operation.
   * @param fromToken The address of the token to sell.
   * @param toToken The address of the token to buy.
   * @param amountIn The amount of the token to sell.
   * @param amountOut The amount of the token transfer to sender.
   * @param connectorName Conenctor name.
   */

  /**
   * @dev Emitted when the user open position.
   * @param key The key to obtain the current position.
   * @param account The address of the owner position.
   * @param index Count current position.
   * @param position The structure of the current position.
   */
  event OpenPosition(bytes32 indexed key, address indexed account, uint256 index, DataTypes.Position position);

  /**
   * @dev Emitted when the user close position.
   * @param key The key to obtain the current position.
   * @param account The address of the owner position.
   * @param position The structure of the current position.
   */
  event ClosePosition(bytes32 indexed key, address indexed account, DataTypes.Position position);

  function fee() external view returns (uint256);

  function positionsIndex(address account) external view returns (uint256);

  function positions(bytes32 key)
    external
    view
    returns (address, address, address, uint256, uint256, string memory, uint64, address);

  function accounts(address owner) external view returns (address);

  function balances(address assets, address owner) external view returns (uint256);

  /**
   * @dev Delegate borrowing power by depositing tokens to the protocol.
   * @param asset The address of the token to deposit.
   * @param amount The amount of the token to deposit.
   */
  function delegate(address asset, uint256 amount) external;

  /**
   * @dev Stop delegating borrowing power by withdraw tokens from the protocol.
   * @param asset The address of the token to withdraw.
   * @param amount The amount of the token to withdraw.
   */
  function undelegate(address asset, uint256 amount) external;

  /**
   * @notice Set a new fee to the router contract.
   * @param _fee The new amount
   */
  function setFee(uint256 _fee) external;

  /**
   * @dev Create a position on the lendings protocol.
   * @param position The structure of the current position.
   * @param data Calldata for the openPositionCallback.
   */
  function openPosition(DataTypes.Position memory position, bytes calldata data) external;

  /**
   * @dev Сloses the user's position and deletes it.
   * @param key The key to obtain the current position.
   * @param data Calldata for the openPositionCallback.
   */
  function closePosition(bytes32 key, bytes calldata data) external;

  /**
   * @dev Called by the ccip contract to open or close a loan position.
   * @param token Address of the token to be deposited.
   * @param amount Amount of the token to be deposited.
   * @param data Calldata to open a loan position.
   */
  function handlePosition(address token, uint256 amount, bytes calldata data) external;

  /**
   * @dev Checks if the user has an account otherwise creates and initializes it.
   * @param owner User address.
   * @return Returns of the user account address.
   */
  function getOrCreateAccount(address owner) external returns (address);

  /**
   * @dev Create position key.
   * @param account Position account owner.
   * @param index Position count account owner.
   * @return Returns the position key
   */
  function getKey(address account, uint256 index) external pure returns (bytes32);

  /**
   * @dev Returns the future address of the account created through create2, necessary for the user interface.
   * @param owner User account address, convert to salt.
   * @return predicted Returns of the user account address.
   */
  function predictDeterministicAddress(address owner) external view returns (address predicted);

  /**
   * @dev Calculates and returns the current commission depending on the amount.
   * @param amount Amount
   * @return feeAmount Returns the protocol fee amount.
   */
  function getFeeAmount(uint256 amount) external view returns (uint256 feeAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IAaveV3Connector } from "../interfaces/connectors/IAaveV3Connector.sol";
import { IPool } from "../interfaces/external/aave-v3/IPool.sol";
import { IPoolDataProvider } from "../interfaces/external/aave-v3/IPoolDataProvider.sol";
import { IPoolAddressesProvider } from "../interfaces/external/aave-v3/IPoolAddressesProvider.sol";

import { Errors } from "../lib/Errors.sol";

contract SparkConnector is IAaveV3Connector {
  using SafeERC20 for IERC20;

  /* ============ Constants ============ */

  /**
   * @dev spark Referral Code
   */
  uint16 internal constant REFERRAL_CODE = 0;

  /**
   * @dev Connector name
   */
  string public constant NAME = "Spark";

  /* ============ Immutables ============ */

  /**
   * @dev spark Lending Pool Provider
   */
  IPoolAddressesProvider immutable ADDRESSES_PROVIDER;

  /**
   * @dev spark Protocol Data Provider
   */
  IPoolDataProvider immutable DATA_PROVIDER;

  /* ============ Constructor ============ */
  constructor(IPoolAddressesProvider addressesProvider, IPoolDataProvider dataProvider) {
    ADDRESSES_PROVIDER = addressesProvider;
    DATA_PROVIDER = dataProvider;
  }

  /* ============ External Functions ============ */

  /// @dev See {IAaveV3Connector-deposit}.
  function deposit(address token, uint256 amount) external {
    IPool spark = IPool(ADDRESSES_PROVIDER.getPool());

    amount = amount == type(uint256).max ? IERC20(token).balanceOf(address(this)) : amount;

    IERC20(token).forceApprove(address(spark), amount);
    spark.supply(token, amount, address(this), REFERRAL_CODE);

    if (!_getisCollateral(token)) {
      spark.setUserUseReserveAsCollateral(token, true);
    }
  }

  /// @dev See {IAaveV3Connector-withdraw}.
  function withdraw(address token, uint256 amount) external {
    IPool spark = IPool(ADDRESSES_PROVIDER.getPool());

    spark.withdraw(token, amount, address(this));
  }

  /// @dev See {IAaveV3Connector-borrow}.
  function borrow(address token, uint256 rateMode, uint256 amount) external {
    IPool spark = IPool(ADDRESSES_PROVIDER.getPool());

    spark.borrow(token, amount, rateMode, REFERRAL_CODE, address(this));
  }

  /// @dev See {IAaveV3Connector-payback}.
  function payback(address token, uint256 amount, uint256 rateMode) external {
    IPool spark = IPool(ADDRESSES_PROVIDER.getPool());

    uint256 debtAmount = getPaybackBalance(token, rateMode, address(this));

    if (amount < debtAmount) revert Errors.InvalidAmountAction();

    IERC20(token).forceApprove(address(spark), debtAmount);

    spark.repay(token, debtAmount, rateMode, address(this));
  }

  /* ============ Public Functions ============ */

  /// @dev See {IAaveV3Connector-getPaybackBalance}.
  function getPaybackBalance(address token, uint256 rateMode, address user) public view returns (uint256) {
    (, uint256 stableDebt, uint256 variableDebt,,,,,,) = DATA_PROVIDER.getUserReserveData(token, user);
    return rateMode == 1 ? stableDebt : variableDebt;
  }

  /// @dev See {IAaveV3Connector-getCollateralBalance}.
  function getCollateralBalance(address token, address user) public view returns (uint256 balance) {
    (balance,,,,,,,,) = DATA_PROVIDER.getUserReserveData(token, user);
  }

  /* ============ Internal Functions ============ */

  /**
   * @dev Checks if collateral is enabled for an asset
   * @param token token address of the asset.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   */
  function _getisCollateral(address token) internal view returns (bool isCollateral) {
    (,,,,,,,, isCollateral) = DATA_PROVIDER.getUserReserveData(token, address(this));
  }
}

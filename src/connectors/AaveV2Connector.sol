// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IAaveV2Connector } from "../interfaces/connectors/IAaveV2Connector.sol";
import { ILendingPool } from "../interfaces/external/aave-v2/ILendingPool.sol";
import { IProtocolDataProvider } from "../interfaces/external/aave-v2/IProtocolDataProvider.sol";
import { ILendingPoolAddressesProvider } from "../interfaces/external/aave-v2/ILendingPoolAddressesProvider.sol";

import { Errors } from "../lib/Errors.sol";

contract AaveV2Connector is IAaveV2Connector {
  using SafeERC20 for IERC20;

  /* ============ Constants ============ */

  /**
   * @dev Aave Referral Code
   */
  uint16 internal constant REFERRAL_CODE = 0;

  /**
   * @dev Connector name
   */
  string public constant NAME = "AaveV2";

  /* ============ Immutables ============ */

  /**
   * @dev Aave Lending Pool Provider
   */
  ILendingPoolAddressesProvider immutable ADDRESSES_PROVIDER;

  /**
   * @dev Aave Protocol Data Provider
   */
  IProtocolDataProvider immutable DATA_PROVIDER;

  /* ============ Constructor ============ */
  constructor(ILendingPoolAddressesProvider addressesProvider, IProtocolDataProvider dataProvider) {
    ADDRESSES_PROVIDER = addressesProvider;
    DATA_PROVIDER = dataProvider;
  }

  /* ============ External Functions ============ */

  /// @dev See {IAaveV2Connector-deposit}.
  function deposit(address token, uint256 amount) external {
    ILendingPool aave = ILendingPool(ADDRESSES_PROVIDER.getLendingPool());

    amount = amount == type(uint256).max ? IERC20(token).balanceOf(address(this)) : amount;

    IERC20(token).forceApprove(address(aave), amount);

    aave.deposit(token, amount, address(this), REFERRAL_CODE);

    if (!_getIsCollateral(token)) {
      aave.setUserUseReserveAsCollateral(token, true);
    }
  }

  /// @dev See {IAaveV2Connector-withdraw}.
  function withdraw(address token, uint256 amount) external {
    ILendingPool aave = ILendingPool(ADDRESSES_PROVIDER.getLendingPool());

    aave.withdraw(token, amount, address(this));
  }

  /// @dev See {IAaveV2Connector-borrow}.
  function borrow(address token, uint256 rateMode, uint256 amount) external {
    ILendingPool aave = ILendingPool(ADDRESSES_PROVIDER.getLendingPool());

    aave.borrow(token, amount, rateMode, REFERRAL_CODE, address(this));
  }

  /// @dev See {IAaveV2Connector-payback}.
  function payback(address token, uint256 amount, uint256 rateMode) external {
    ILendingPool aave = ILendingPool(ADDRESSES_PROVIDER.getLendingPool());

    uint256 debtAmount = getPaybackBalance(token, rateMode, address(this));

    if (amount < debtAmount) revert Errors.InvalidAmountAction();

    IERC20(token).forceApprove(address(aave), debtAmount);

    aave.repay(token, debtAmount, rateMode, address(this));
  }

  /* ============ Public Functions ============ */

  /// @dev See {IAaveV2Connector-getPaybackBalance}.
  function getPaybackBalance(address token, uint256 rateMode, address user) public view returns (uint256) {
    (, uint256 stableDebt, uint256 variableDebt,,,,,,) = DATA_PROVIDER.getUserReserveData(token, user);
    return rateMode == 1 ? stableDebt : variableDebt;
  }

  /// @dev See {IAaveV2Connector-getCollateralBalance}.
  function getCollateralBalance(address token, address user) public view returns (uint256 balance) {
    (balance,,,,,,,,) = DATA_PROVIDER.getUserReserveData(token, user);
  }

  /* ============ Internal Functions ============ */

  /**
   * @dev Checks if collateral is enabled for an asset
   * @param token token address of the asset.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
   */
  function _getIsCollateral(address token) internal view returns (bool IsCollateral) {
    (,,,,,,,, IsCollateral) = DATA_PROVIDER.getUserReserveData(token, address(this));
  }
}

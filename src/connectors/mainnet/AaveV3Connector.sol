// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IAaveV3Connector } from "../../interfaces/connectors/IAaveV3Connector.sol";
import { IPool } from "../../interfaces/external/aave-v3/IPool.sol";
import { IPoolDataProvider } from "../../interfaces/external/aave-v3/IPoolDataProvider.sol";
import { IPoolAddressesProvider } from "../../interfaces/external/aave-v3/IPoolAddressesProvider.sol";

import { Errors } from "../../lib/Errors.sol";

contract AaveV3Connector is IAaveV3Connector {
  using SafeERC20 for IERC20;

  /* ============ Constants ============ */

  /**
   * @dev Aave Referral Code
   */
  uint16 internal constant REFERRAL_CODE = 0;

  /**
   * @dev Connector name
   */
  string public constant NAME = "AaveV3";

  /* ============ Immutables ============ */

  /**
   * @dev Aave Lending Pool Provider
   */
  IPoolAddressesProvider constant ADDRESSES_PROVIDER =
    IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e);

  /**
   * @dev Aave Protocol Data Provider
   */
  IPoolDataProvider constant DATA_PROVIDER = IPoolDataProvider(0x7B4EB56E7CD4b454BA8ff71E4518426369a138a3);

  /* ============ External Functions ============ */

  /// @dev See {IAaveV3Connector-deposit}.
  function deposit(address token, uint256 amount) external {
    IPool aave = IPool(ADDRESSES_PROVIDER.getPool());

    amount = amount == type(uint256).max ? IERC20(token).balanceOf(address(this)) : amount;

    IERC20(token).forceApprove(address(aave), amount);
    aave.supply(token, amount, address(this), REFERRAL_CODE);

    if (!_getisCollateral(token)) {
      aave.setUserUseReserveAsCollateral(token, true);
    }
  }

  /// @dev See {IAaveV3Connector-withdraw}.
  function withdraw(address token, uint256 amount) external {
    IPool aave = IPool(ADDRESSES_PROVIDER.getPool());

    aave.withdraw(token, amount, address(this));
  }

  /// @dev See {IAaveV3Connector-borrow}.
  function borrow(address token, uint256 rateMode, uint256 amount) external {
    IPool aave = IPool(ADDRESSES_PROVIDER.getPool());

    aave.borrow(token, amount, rateMode, REFERRAL_CODE, address(this));
  }

  /// @dev See {IAaveV3Connector-payback}.
  function payback(address token, uint256 amount, uint256 rateMode) external {
    IPool aave = IPool(ADDRESSES_PROVIDER.getPool());

    uint256 debtAmount = getPaybackBalance(token, rateMode, address(this));

    if (amount < debtAmount) revert Errors.InvalidAmountAction();

    IERC20(token).forceApprove(address(aave), debtAmount);

    aave.repay(token, debtAmount, rateMode, address(this));
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

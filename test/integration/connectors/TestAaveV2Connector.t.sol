// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { Connectors } from "contracts/Connectors.sol";
import { AaveV2Connector } from "contracts/connectors/mainnet/AaveV2Connector.sol";
import { DataTypes } from "contracts/lib/DataTypes.sol";
import { ILendingPool } from "contracts/interfaces/external/aave-v2/ILendingPool.sol";
import { IProtocolDataProvider } from "contracts/interfaces/external/aave-v2/IProtocolDataProvider.sol";
import { ILendingPoolAddressesProvider } from "contracts/interfaces/external/aave-v2/ILendingPoolAddressesProvider.sol";

import { Tokens } from "../../utils/tokens.sol";

contract LendingHelper is Tokens {
  uint256 RATE_TYPE = 2;
  string NAME = "AaveV2";

  AaveV2Connector aaveV2Connector;

  ILendingPoolAddressesProvider internal constant aaveProvider =
    ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);
  IProtocolDataProvider internal constant aaveDataProvider =
    IProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);

  function setUp() public {
    string memory url = vm.rpcUrl("mainnet");
    uint256 forkId = vm.createFork(url);
    vm.selectFork(forkId);

    aaveV2Connector = new AaveV2Connector();
  }

  function _getCollateralAmt(address token, address recipient) internal view returns (uint256 collateralAmount) {
    collateralAmount = aaveV2Connector.getCollateralBalance(token, recipient);
  }

  function _getBorrowAmt(address token, address recipient) internal view returns (uint256 borrowAmount) {
    borrowAmount = aaveV2Connector.getPaybackBalance(token, recipient, RATE_TYPE);
  }

  function _getPaybackData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.payback.selector, token, amount, RATE_TYPE);
  }

  function _getWithdrawData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.withdraw.selector, token, amount);
  }

  function _getDepositData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.deposit.selector, token, amount);
  }

  function _getBorrowData(address token, uint256 amount, uint256 rate) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.borrow.selector, token, rate, amount);
  }

  function _execute(bytes memory data) internal {
    (bool success,) = address(aaveV2Connector).delegatecall(data);
    require(success);
  }
}

contract TestAaveV2Connector is LendingHelper {
  uint256 public RAY = 1e27;
  uint256 public SECONDS_OF_THE_YEAR = 365 days;

  function test_Deposit() public {
    uint256 depositAmount = 1000 ether;
    _depositDai(depositAmount);
    assertApproxEqAbs(_getCollateralAmt(getToken("dai"), address(this)), depositAmount, 1);
  }

  function test_Deposit_ReserveAsCollateral() public {
    uint256 depositAmount = 1000 ether;
    _depositDai(depositAmount);

    ILendingPool aave = ILendingPool(aaveProvider.getLendingPool());
    aave.setUserUseReserveAsCollateral(getToken("dai"), false);

    _depositDai(depositAmount);
    assertApproxEqAbs(_getCollateralAmt(getToken("dai"), address(this)), depositAmount * 2, 1);
  }

  function test_DepositMax() public {
    uint256 depositAmount = 1000 ether;
    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), type(uint256).max));
    assertApproxEqAbs(_getCollateralAmt(getToken("dai"), address(this)), depositAmount, 1);
  }

  function test_Borrow() public {
    uint256 depositAmount = 1000 ether;
    _depositDai(depositAmount);

    uint256 borrowAmount = 0.1 ether;
    _borrowWeth(borrowAmount, 2);
    assertEq(borrowAmount, _getBorrowAmt(getToken("weth"), address(this)));
  }

  function test_Payback() public {
    uint256 depositAmount = 1000 ether;
    _depositDai(depositAmount);

    uint256 borrowAmount = 0.1 ether;
    _borrowWeth(borrowAmount, 2);
    _paybackWeth(borrowAmount);

    assertEq(0, _getBorrowAmt(getToken("weth"), address(this)));
    assertEq(0, ERC20(getToken("weth")).balanceOf(address(this)));
  }

  function test_PaybackMax() public {
    uint256 depositAmount = 1000 ether;
    _depositDai(depositAmount);

    uint256 borrowAmount = 0.1 ether;
    _borrowWeth(borrowAmount, 2);
    _paybackWeth(type(uint256).max);

    assertEq(0, _getBorrowAmt(getToken("weth"), address(this)));
    assertEq(0, ERC20(getToken("weth")).balanceOf(address(this)));
  }

  function test_Withdraw() public {
    uint256 depositAmount = 1000 ether;
    _depositDai(depositAmount);

    uint256 borrowAmount = 0.1 ether;
    _borrowWeth(borrowAmount, 2);
    _paybackWeth(type(uint256).max);
    _withdraw(depositAmount);

    assertEq(0, _getCollateralAmt(getToken("dai"), address(this)));
  }

  function _depositDai(uint256 _amount) internal {
    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), _amount);

    _execute(_getDepositData(getToken("dai"), _amount));
  }

  function _borrowWeth(uint256 _amount, uint256 _rate) internal {
    _execute(_getBorrowData(getToken("weth"), _amount, _rate));
  }

  function _paybackWeth(uint256 _amount) internal {
    _execute(_getPaybackData(getToken("weth"), _amount));
  }

  function _withdraw(uint256 _amount) internal {
    _execute(_getWithdrawData(getToken("dai"), _amount));
  }
}

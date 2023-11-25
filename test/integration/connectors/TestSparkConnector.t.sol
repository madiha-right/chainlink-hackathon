// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { SparkConnector } from "contracts/connectors/SparkConnector.sol";
import { DataTypes } from "contracts/lib/DataTypes.sol";
import { IPool } from "contracts/interfaces/external/aave-v3/IPool.sol";
import { IPoolDataProvider } from "contracts/interfaces/external/aave-v3/IPoolDataProvider.sol";
import { IPoolAddressesProvider } from "contracts/interfaces/external/aave-v3/IPoolAddressesProvider.sol";

import { Tokens } from "../../utils/tokens.sol";

contract LendingHelper is Tokens {
  uint256 RATE_TYPE = 2;
  string NAME = "AaveV3";

  SparkConnector sparkConnector;

  IPoolAddressesProvider internal constant sparkProvider =
    IPoolAddressesProvider(0x02C3eA4e34C0cBd694D2adFa2c690EECbC1793eE);
  IPoolDataProvider internal constant sparkDataProvider = IPoolDataProvider(0xFc21d6d146E6086B8359705C8b28512a983db0cb);

  function setUp() public {
    string memory url = vm.rpcUrl("mainnet");
    uint256 forkId = vm.createFork(url);
    vm.selectFork(forkId);

    sparkConnector = new SparkConnector(sparkProvider, sparkDataProvider);
  }

  function _getPaybackData(uint256 amount, address token) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.payback.selector, token, amount, RATE_TYPE);
  }

  function _getWithdrawData(uint256 amount, address token) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.withdraw.selector, token, amount);
  }

  function _getDepositData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.deposit.selector, token, amount);
  }

  function _getBorrowData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.borrow.selector, token, RATE_TYPE, amount);
  }

  function _execute(bytes memory data) public {
    (bool success,) = address(sparkConnector).delegatecall(data);
    require(success);
  }
}

contract TestAaveV3Connector is LendingHelper {
  uint256 public SECONDS_OF_THE_YEAR = 365 days;
  uint256 public RAY = 1e27;

  function test_Deposit() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    assertEq(depositAmount, sparkConnector.getCollateralBalance(getToken("dai"), address(this)));
  }

  function test_Deposit_ReserveAsCollateral() public {
    uint256 depositAmount = 1000 ether;
    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    IPool spark = IPool(sparkProvider.getPool());
    spark.setUserUseReserveAsCollateral(getToken("dai"), false);

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    assertEq(sparkConnector.getCollateralBalance(getToken("dai"), address(this)), depositAmount * 2);
  }

  function test_Deposit_Max() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), type(uint256).max));

    assertEq(depositAmount, sparkConnector.getCollateralBalance(getToken("dai"), address(this)));
  }

  function test_borrow() public {
    uint256 depositAmount = 1000 ether;

    deal(getToken("weth"), address(this), depositAmount);

    _execute(_getDepositData(getToken("weth"), depositAmount));

    uint256 borrowAmount = 1 ether;
    _execute(_getBorrowData(getToken("dai"), borrowAmount));

    assertEq(borrowAmount, sparkConnector.getPaybackBalance(getToken("dai"), RATE_TYPE, address(this)));
  }

  function test_Payback() public {
    uint256 depositAmount = 1000 ether;

    deal(getToken("weth"), address(this), 1000 ether);

    _execute(_getDepositData(getToken("weth"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("dai"), borrowAmount));

    _execute(_getPaybackData(borrowAmount, getToken("dai")));

    assertEq(0, sparkConnector.getPaybackBalance(getToken("dai"), RATE_TYPE, address(this)));
  }

  function test_Payback_Max() public {
    uint256 depositAmount = 1000 ether;

    deal(getToken("weth"), address(this), 1000 ether);

    _execute(_getDepositData(getToken("weth"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("dai"), borrowAmount));

    _execute(_getPaybackData(type(uint256).max, getToken("dai")));

    assertEq(0, sparkConnector.getPaybackBalance(getToken("dai"), RATE_TYPE, address(this)));
  }

  function test_Withdraw() public {
    uint256 depositAmount = 1000 ether;

    deal(getToken("weth"), address(this), 1000 ether);

    _execute(_getDepositData(getToken("weth"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("dai"), borrowAmount));

    _execute(_getPaybackData(borrowAmount, getToken("dai")));
    _execute(_getWithdrawData(depositAmount, getToken("weth")));

    assertEq(0, sparkConnector.getCollateralBalance(getToken("weth"), address(this)));
  }
}

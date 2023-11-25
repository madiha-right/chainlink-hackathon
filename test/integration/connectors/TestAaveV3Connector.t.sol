// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { AaveV3Connector } from "contracts/connectors/AaveV3Connector.sol";
import { DataTypes } from "contracts/lib/DataTypes.sol";
import { IPool } from "contracts/interfaces/external/aave-v3/IPool.sol";
import { IPoolDataProvider } from "contracts/interfaces/external/aave-v3/IPoolDataProvider.sol";
import { IPoolAddressesProvider } from "contracts/interfaces/external/aave-v3/IPoolAddressesProvider.sol";

import { Tokens } from "../../utils/tokens.sol";

contract LendingHelper is Tokens {
  uint256 RATE_TYPE = 2;
  string NAME = "AaveV3";

  AaveV3Connector aaveV3Connector;

  IPoolAddressesProvider internal constant aaveProvider =
    IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e);
  IPoolDataProvider internal constant aaveDataProvider = IPoolDataProvider(0x7B4EB56E7CD4b454BA8ff71E4518426369a138a3);

  function setUp() public {
    string memory url = vm.rpcUrl("mainnet");
    uint256 forkId = vm.createFork(url);
    vm.selectFork(forkId);

    aaveV3Connector = new AaveV3Connector(aaveProvider, aaveDataProvider);
  }

  function _getPaybackData(uint256 amount, address token) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV3Connector.payback.selector, token, amount, RATE_TYPE);
  }

  function _getWithdrawData(uint256 amount, address token) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV3Connector.withdraw.selector, token, amount);
  }

  function _getDepositData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV3Connector.deposit.selector, token, amount);
  }

  function _getBorrowData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV3Connector.borrow.selector, token, RATE_TYPE, amount);
  }

  function _execute(bytes memory data) public {
    (bool success,) = address(aaveV3Connector).delegatecall(data);
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

    assertEq(depositAmount, aaveV3Connector.getCollateralBalance(getToken("dai"), address(this)));
  }

  function test_Deposit_ReserveAsCollateral() public {
    uint256 depositAmount = 1000 ether;
    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    IPool aave = IPool(aaveProvider.getPool());
    aave.setUserUseReserveAsCollateral(getToken("dai"), false);

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    assertEq(aaveV3Connector.getCollateralBalance(getToken("dai"), address(this)), depositAmount * 2);
  }

  function test_Deposit_Max() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), type(uint256).max));

    assertEq(depositAmount, aaveV3Connector.getCollateralBalance(getToken("dai"), address(this)));
  }

  function test_borrow() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("weth"), borrowAmount));

    assertEq(borrowAmount, aaveV3Connector.getPaybackBalance(getToken("weth"), RATE_TYPE, address(this)));
  }

  function test_Payback() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("weth"), borrowAmount));

    _execute(_getPaybackData(borrowAmount, getToken("weth")));

    assertEq(0, aaveV3Connector.getPaybackBalance(getToken("weth"), RATE_TYPE, address(this)));
  }

  function test_Payback_Max() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("weth"), borrowAmount));

    _execute(_getPaybackData(type(uint256).max, getToken("weth")));

    assertEq(0, aaveV3Connector.getPaybackBalance(getToken("weth"), RATE_TYPE, address(this)));
  }

  function test_Withdraw() public {
    uint256 depositAmount = 1000 ether;

    vm.prank(getToken("dai"));
    ERC20(getToken("dai")).transfer(address(this), depositAmount);

    _execute(_getDepositData(getToken("dai"), depositAmount));

    uint256 borrowAmount = 0.1 ether;
    _execute(_getBorrowData(getToken("weth"), borrowAmount));

    _execute(_getPaybackData(borrowAmount, getToken("weth")));
    _execute(_getWithdrawData(depositAmount, getToken("dai")));

    assertEq(0, aaveV3Connector.getCollateralBalance(getToken("dai"), address(this)));
  }
}

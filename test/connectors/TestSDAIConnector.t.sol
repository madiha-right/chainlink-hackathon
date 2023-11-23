// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { console } from "forge-std/console.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { TestBase } from "../TestBase.t.sol";
import { SDAIConnector } from "../../src/connectors/SDAIConnector.sol";

contract TestSDAIConnector is TestBase {
  SDAIConnector sDAIConnector;

  function setUp() public {
    sDAIConnector = new SDAIConnector(address(this));

    deal(DAI, address(sDAIConnector), DAI_DEPOSIT_AMOUNT);
  }

  function testFuzz_deposit(uint256 amount) public {
    amount = bound(amount, 1e18, IERC20(DAI).balanceOf(address(sDAIConnector)));
    uint256 shares = sDAIConnector.deposit(DAI, amount, address(this));
    assertEq(shares, IERC20(SDAI).balanceOf(address(this)));
  }

  function testFuzz_withdraw(uint256 amount) public {
    amount = bound(amount, 1e18, IERC20(DAI).balanceOf(address(sDAIConnector)));
    uint256 shares = sDAIConnector.deposit(DAI, amount, address(this));
    IERC20(SDAI).approve(address(sDAIConnector), shares);
    sDAIConnector.withdraw(DAI, shares, address(this));
    assertApproxEqAbs(IERC20(DAI).balanceOf(address(this)), amount, 2);
  }

  function test_getYieldBearingAsset() public {
    assertEq(sDAIConnector.getYieldBearingAsset(DAI), SDAI);
  }

  function test_Revert_Forbidden() public {
    vm.expectRevert(Forbidden.selector);
    sDAIConnector.borrow(DAI, DAI_DEPOSIT_AMOUNT, address(this));
  }

  function test_RevertWhen_CallerIsNotOwner() public {
    vm.startPrank(address(0x123));

    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    sDAIConnector.deposit(DAI, DAI_DEPOSIT_AMOUNT, address(this));
    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    sDAIConnector.borrow(DAI, DAI_DEPOSIT_AMOUNT, address(this));
    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    sDAIConnector.withdraw(DAI, DAI_DEPOSIT_AMOUNT, address(this));

    vm.stopPrank();
  }
}

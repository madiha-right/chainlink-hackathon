// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Vault } from "../src/Vault.sol";
import { TestBase } from "./TestBase.t.sol";

contract TestVault is TestBase {
  function setUp() public {
    DAI_VAULT = new Vault(IERC20(DAI), 'vault DAI', 'vDAI', address(this));
  }

  function test_revertNotOwner() public {
    vm.startPrank(address(0x123));

    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    DAI_VAULT.deposit(DAI_DEPOSIT_AMOUNT, address(this));
    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    DAI_VAULT.mint(DAI_DEPOSIT_AMOUNT, address(this));
    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    DAI_VAULT.withdraw(DAI_DEPOSIT_AMOUNT, address(this), address(this));
    vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x123)));
    DAI_VAULT.redeem(DAI_DEPOSIT_AMOUNT, address(this), address(this));

    vm.stopPrank();
  }

  function test_name() public {
    assertEq(DAI_VAULT.name(), "vault DAI");
  }

  function test_symbol() public {
    assertEq(DAI_VAULT.symbol(), "vDAI");
  }
}

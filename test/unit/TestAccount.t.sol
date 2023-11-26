// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { Errors } from "contracts/lib/Errors.sol";
import { AddressesProvider } from "contracts/AddressesProvider.sol";
import { AccountV1 } from "contracts/Account.sol";

import { ERC20Mock } from "mocks/ERC20Mock.sol";

contract TestAccount is Test {
  AccountV1 account;
  ERC20Mock tokenMock;

  mapping(uint256 => address) public test2;

  function setUp() public {
    tokenMock = new ERC20Mock('Mock', 'MCK', msg.sender, 1000000 ether);

    address addressesProvider = address(new AddressesProvider(address(this)));

    account = new AccountV1(addressesProvider);
    account.initialize(msg.sender, IAddressesProvider(addressesProvider));
  }

  // Main identifiers
  function test_claimERC20Token() public {
    uint256 amount = 1000 ether;
    tokenMock.mint(address(account), amount);

    uint256 balanceBefore = tokenMock.balanceOf(msg.sender);

    vm.prank(msg.sender);
    account.claimTokens(address(tokenMock), amount);

    uint256 balanceAfter = tokenMock.balanceOf(msg.sender);

    assertEq(amount, balanceAfter - balanceBefore);
  }

  function test_claimERC20Token_Max() public {
    uint256 amount = 1000 ether;
    tokenMock.mint(address(account), amount);

    uint256 balanceBefore = tokenMock.balanceOf(msg.sender);

    vm.prank(msg.sender);
    account.claimTokens(address(tokenMock), type(uint256).max);

    uint256 balanceAfter = tokenMock.balanceOf(msg.sender);

    assertEq(amount, balanceAfter - balanceBefore);
  }

  receive() external payable { }
}

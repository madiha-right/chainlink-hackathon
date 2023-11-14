// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TestBase } from "../TestBase.t.sol";
import { SDAIConnector } from "../../src/connectors/SDAIConnector.sol";

contract TestSDAIConnector is TestBase {
  SDAIConnector sDAIConnector;

  function setUp() public {
    sDAIConnector = new SDAIConnector(address(this));
  }

  function testDeposit() public { }

  function testRevertBorrow() public { }

  function testWithdraw() public { }

  function testGetUnderlyingAsset() public { }

  function testGetYieldSource() public { }
}

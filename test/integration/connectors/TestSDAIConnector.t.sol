// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { SDAIConnector } from "contracts/connectors/SDAIConnector.sol";
import { DataTypes } from "contracts/lib/DataTypes.sol";

import { Tokens } from "../../utils/tokens.sol";

contract LendingHelper is Tokens {
  string NAME = "sDAI";

  SDAIConnector sDAIConnector;

  function setUp() public {
    // string memory url = vm.rpcUrl("mainnet");
    // uint256 forkId = vm.createFork(url);
    // vm.selectFork(forkId);

    sDAIConnector = new SDAIConnector();
  }

  function _getDepositData(uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sDAIConnector.deposit.selector, amount);
  }

  function _getRedeemData(uint256 shares) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sDAIConnector.redeem.selector, shares);
  }

  function _execute(bytes memory data) public {
    (bool success,) = address(sDAIConnector).delegatecall(data);
    require(success);
  }
}

contract TestSDAIConnector is LendingHelper {
  function test_Deposit() public {
    uint256 depositAmount = 1000 ether;

    deal(getToken("dai"), address(this), depositAmount);

    _execute(_getDepositData(depositAmount));
    assertApproxEqAbs(sDAIConnector.getDepositBalance(address(this)), depositAmount, 1);
  }

  function test_Redeem() public {
    uint256 depositAmount = 1000 ether;

    deal(getToken("dai"), address(this), depositAmount);

    _execute(_getDepositData(depositAmount));

    uint256 shares = sDAIConnector.getShares(address(this));

    _execute(_getRedeemData(shares));
    assertApproxEqAbs(IERC20(getToken("dai")).balanceOf(address(this)), depositAmount, 1);
  }
}

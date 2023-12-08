// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { console } from "forge-std/Console.sol";
import { Script } from "forge-std/Script.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { DataTypes } from "contracts/lib/DataTypes.sol";
import { PercentageMath } from "contracts/lib/PercentageMath.sol";

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";
import { IConnector } from "contracts/interfaces/IConnector.sol";

import { Constants } from "./utils/Constants.sol";
import { Tokens } from "utils/Tokens.sol";

contract Delegate is Constants, Tokens, Script {
  using SafeERC20 for IERC20;

  function run() public {
    uint256 pk = vm.envUint("PRIVATE_KEY");
    // address account = vm.addr(pk);
    vm.startBroadcast(pk);

    _delegate(getToken("dai"), 3000 ether);

    vm.stopBroadcast();
  }

  function _delegate(address token, uint256 amount) private {
    address router = ADDRESSES_PROVIDER.getRouter();

    IERC20(token).forceApprove(address(router), amount);
    IRouter(router).delegate(address(token), amount);
  }
}

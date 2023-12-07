// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/Console.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Vault } from "contracts/Vault.sol";
import { AaveV2Connector } from "contracts/connectors/mainnet/AaveV2Connector.sol";
import { AaveV3Connector } from "contracts/connectors/mainnet/AaveV3Connector.sol";
import { CompoundV2Connector } from "contracts/connectors/mainnet/CompoundV2Connector.sol";
import { SparkConnector } from "contracts/connectors/mainnet/SparkConnector.sol";
import { SDAIConnector } from "contracts/connectors/mainnet/SDAIConnector.sol";

import { Tokens } from "utils/Tokens.sol";

contract DeployPeriphery is Tokens, Script {
  function run() public {
    uint256 pk = vm.envUint("PRIVATE_KEY");
    // address account = vm.addr(pk);
    vm.startBroadcast(pk);

    _deployVaults();
    // _deployYieldConnectors();
    _deployLendingConnectors();

    vm.stopBroadcast();
  }

  function _deployVaults() private {
    Vault wethVault = new Vault(IERC20(getToken('weth')), 'vault WETH', 'vWETH');
    Vault daiVault = new Vault(IERC20(getToken('dai')), 'vault DAI', 'vDAI');

    console.log("wethVault", address(wethVault));
    console.log("daiVault", address(daiVault));
  }

  // function _deployYieldConnectors() private {
  //   SDAIConnector sDAIConnector = new SDAIConnector();

  //   console.log("sDAIConnector", sDAIConnector.NAME(), address(sDAIConnector));
  // }

  function _deployLendingConnectors() private {
    // AaveV2Connector aaveV2Connector = new AaveV2Connector();
    AaveV3Connector aaveV3Connector = new AaveV3Connector();
    // CompoundV2Connector compoundV2Connector = new CompoundV2Connector();
    // SparkConnector sparkConnector = new SparkConnector();

    // console.log("aaveV2Connector", aaveV2Connector.NAME(), address(aaveV2Connector));
    console.log("aaveV3Connector", aaveV3Connector.NAME(), address(aaveV3Connector));
    // console.log("compoundV2Connector", compoundV2Connector.NAME(), address(compoundV2Connector));
    // console.log("sparkConnector", sparkConnector.NAME(), address(sparkConnector));
  }
}

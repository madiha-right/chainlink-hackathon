// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { DeployCoreContracts } from "../core.sol";
import { DeployMainnetConnectors } from "./MainnetConnectors.sol";

contract DeployMainnetContracts is DeployCoreContracts, DeployMainnetConnectors {
  function setUp() public {
    string memory url = vm.rpcUrl("mainnet");
    uint256 forkId = vm.createFork(url);
    vm.selectFork(forkId);

    (string[] memory names, address[] memory connectors) = deployConnectors();
    deployContracts(names, connectors);
  }
}

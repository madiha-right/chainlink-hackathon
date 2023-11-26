// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { AaveV2Connector } from "contracts/connectors/mainnet/AaveV2Connector.sol";
import { AaveV3Connector } from "contracts/connectors/mainnet/AaveV3Connector.sol";
import { CompoundV2Connector } from "contracts/connectors/mainnet/CompoundV2Connector.sol";
import { SparkConnector } from "contracts/connectors/mainnet/SparkConnector.sol";
import { SDAIConnector } from "contracts/connectors/mainnet/SDAIConnector.sol";

contract DeployMainnetConnectors {
  AaveV2Connector public aaveV2Connector;
  AaveV3Connector public aaveV3Connector;
  CompoundV2Connector public compoundV2Connector;
  SparkConnector public sparkConnector;
  SDAIConnector public sDAIConnector;

  function deployConnectors() public returns (string[] memory _names, address[] memory _connectors) {
    _deployYieldConnectors();
    _deployLendingConnectors();

    _names = new string[](5);
    // lending connectors
    _names[0] = aaveV2Connector.NAME();
    _names[1] = aaveV3Connector.NAME();
    _names[2] = compoundV2Connector.NAME();
    _names[3] = sparkConnector.NAME();
    // yield connectors
    _names[4] = sDAIConnector.NAME();

    _connectors = new address[](5);
    // lending connectors
    _connectors[0] = address(aaveV2Connector);
    _connectors[1] = address(aaveV3Connector);
    _connectors[2] = address(compoundV2Connector);
    _connectors[3] = address(sparkConnector);
    // yield connectors
    _connectors[4] = address(sDAIConnector);

    return (_names, _connectors);
  }

  function _deployLendingConnectors() private {
    aaveV2Connector = new AaveV2Connector();
    aaveV3Connector = new AaveV3Connector();
    compoundV2Connector = new CompoundV2Connector();
    sparkConnector = new SparkConnector();
  }

  function _deployYieldConnectors() private {
    sDAIConnector = new SDAIConnector();
  }
}

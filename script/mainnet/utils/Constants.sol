// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { ISDAIConnector } from "contracts/interfaces/connectors/ISDAIConnector.sol";
import { IAaveV2Connector } from "contracts/interfaces/connectors/IAaveV2Connector.sol";
import { IAaveV3Connector } from "contracts/interfaces/connectors/IAaveV3Connector.sol";
import { ICompoundV2Connector } from "contracts/interfaces/connectors/ICompoundV2Connector.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";
import { IConnector } from "contracts/interfaces/IConnector.sol";

contract Constants {
  IAddressesProvider constant ADDRESSES_PROVIDER = IAddressesProvider(0x54287AaB4D98eA51a3B1FBceE56dAf27E04a56A6);

  ISDAIConnector constant SDAI_CONNECTOR = ISDAIConnector(0x5f246ADDCF057E0f778CD422e20e413be70f9a0c);
  IAaveV2Connector constant AAVE_V2_CONNECTOR = IAaveV2Connector(0xaD82Ecf79e232B0391C5479C7f632aA1EA701Ed1);
  IAaveV3Connector constant AAVE_V3_CONNECTOR = IAaveV3Connector(0x4Dd5336F3C0D70893A7a86c6aEBe9B953E87c891);
  ICompoundV2Connector constant COMPOUND_V2_CONNECTOR = ICompoundV2Connector(0x91A1EeE63f300B8f41AE6AF67eDEa2e2ed8c3f79);
  IAaveV3Connector constant SPARK_CONNECTOR = IAaveV3Connector(0xBe6Eb4ACB499f992ba2DaC7CAD59d56DA9e0D823);

  address WETH_VAULT = 0xEC7cb8C3EBE77BA6d284F13296bb1372A8522c5F;
  address DAI_VAULT = 0x3C2BafebbB0c8c58f39A976e725cD20D611d01e9;

  uint256 constant RATE_TYPE = 2;
}

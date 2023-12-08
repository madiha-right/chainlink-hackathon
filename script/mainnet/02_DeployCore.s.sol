// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/Console.sol";

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";

import { Proxy } from "contracts/Proxy.sol";
import { AccountV1 } from "contracts/Account.sol";
import { Router } from "contracts/Router.sol";
import { Configurator } from "contracts/Configurator.sol";
import { ACLManager } from "contracts/ACLManager.sol";
import { Connectors } from "contracts/Connectors.sol";
import { Vaults } from "contracts/Vaults.sol";
import { Ccip } from "contracts/Ccip.sol";
import { AddressesProvider } from "contracts/AddressesProvider.sol";

import { Tokens } from "utils/Tokens.sol";
import { Constants } from "./utils/Constants.sol";

contract DeployCore is Constants, Tokens, Script {
  AddressesProvider addressesProvider;
  Configurator configurator;

  address public owner;

  function run() public {
    uint256 pk = vm.envUint("PRIVATE_KEY");
    owner = vm.addr(pk);

    vm.startBroadcast(pk);

    _deployCoreContracts();
    _deployProxyContracts();
    _setConfigs();

    vm.stopBroadcast();
  }

  function _deployCoreContracts() private {
    addressesProvider = new AddressesProvider(owner);
    addressesProvider.setAddress(bytes32("ACL_ADMIN"), owner);

    ACLManager aclManager = new ACLManager(IAddressesProvider(address(addressesProvider)));
    Connectors connectors = new Connectors(address(addressesProvider));
    Vaults vaults = new Vaults(address(addressesProvider));
    (address ccipRouter,, address link) = getCcipInfo();
    Ccip ccip = new Ccip(address(addressesProvider), ccipRouter, link);

    console.log("addressesProvider", address(addressesProvider));

    addressesProvider.setAddress(bytes32("ACL_MANAGER"), address(aclManager));
    addressesProvider.setAddress(bytes32("CONNECTORS"), address(connectors));
    addressesProvider.setAddress(bytes32("VAULTS"), address(vaults));
    addressesProvider.setAddress(bytes32("CCIP"), address(ccip));

    aclManager.addConnectorAdmin(owner);
    aclManager.addVaultAdmin(owner);
    aclManager.addRouterAdmin(owner);
  }

  function _deployProxyContracts() private {
    configurator = new Configurator();
    Router router = new Router(IAddressesProvider(address(addressesProvider)));

    addressesProvider.setRouterImpl(address(router));
    addressesProvider.setConfiguratorImpl(address(configurator));

    configurator = Configurator(addressesProvider.getConfigurator());
    router = Router(payable(addressesProvider.getRouter()));

    AccountV1 accountImpl = new AccountV1(address(addressesProvider));
    Proxy accountProxy = new Proxy(address(addressesProvider));

    addressesProvider.setAddress(bytes32("ACCOUNT"), address(accountImpl));
    // addressesProvider.setAddress(bytes32("TREASURY"), TREASURY);
    addressesProvider.setAddress(bytes32("ACCOUNT_PROXY"), address(accountProxy));
  }

  function _setConfigs() private {
    string[] memory _names = new string[](5);
    _names[0] = SDAI_CONNECTOR.NAME();
    _names[1] = AAVE_V2_CONNECTOR.NAME();
    _names[2] = AAVE_V3_CONNECTOR.NAME();
    _names[3] = COMPOUND_V2_CONNECTOR.NAME();
    _names[4] = SPARK_CONNECTOR.NAME();

    address[] memory _connectors = new address[](5);
    _connectors[0] = address(SDAI_CONNECTOR); // sDAI connector
    _connectors[1] = address(AAVE_V2_CONNECTOR); // aave v2 connector
    _connectors[2] = address(AAVE_V3_CONNECTOR); // aave v3 connector
    _connectors[3] = address(COMPOUND_V2_CONNECTOR); // compound v2 connector
    _connectors[4] = address(SPARK_CONNECTOR); // spark connector

    address[] memory _vaults = new address[](2);
    _vaults[0] = WETH_VAULT; // weth vault
    _vaults[1] = DAI_VAULT; // dai vault

    configurator.addConnectors(_names, _connectors);
    configurator.addVaults(_vaults);
    configurator.setFee(3);
  }
}

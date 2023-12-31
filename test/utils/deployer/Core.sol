// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";

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

contract DeployCoreContracts is Tokens, Test {
  Router public router;
  AccountV1 public accountImpl;
  AddressesProvider addressesProvider;

  address public owner = makeAddr("owner");

  address public ACL_ADMIN = makeAddr("ACL_ADMIN");
  address public CONNECTOR_ADMIN = makeAddr("CONNECTOR_ADMIN");
  address public VAULT_ADMIN = makeAddr("VAULT_ADMIN");
  address public ROUTER_ADMIN = makeAddr("ROUTER_ADMIN");
  address public TREASURY = makeAddr("TREASURY");

  function deployContracts(string[] memory _names, address[] memory _connectors, address[] memory _vaults) public {
    vm.startPrank(owner);
    addressesProvider = new AddressesProvider(owner);
    addressesProvider.setAddress(bytes32("ACL_ADMIN"), ACL_ADMIN);
    vm.stopPrank();

    ACLManager aclManager = new ACLManager(IAddressesProvider(address(addressesProvider)));
    Connectors connectors = new Connectors(address(addressesProvider));
    Vaults vaults = new Vaults(address(addressesProvider));
    (address ccipRouter,, address link) = getCcipInfo();
    Ccip ccip = new Ccip(address(addressesProvider), ccipRouter, link);

    vm.startPrank(ACL_ADMIN);
    aclManager.addConnectorAdmin(CONNECTOR_ADMIN);
    aclManager.addVaultAdmin(VAULT_ADMIN);
    aclManager.addRouterAdmin(ROUTER_ADMIN);
    vm.stopPrank();

    vm.startPrank(owner);
    addressesProvider.setAddress(bytes32("ACL_MANAGER"), address(aclManager));
    addressesProvider.setAddress(bytes32("CONNECTORS"), address(connectors));
    addressesProvider.setAddress(bytes32("VAULTS"), address(vaults));
    addressesProvider.setAddress(bytes32("CCIP"), address(ccip));

    Configurator configurator = new Configurator();

    router = new Router(IAddressesProvider(address(addressesProvider)));
    addressesProvider.setRouterImpl(address(router));
    addressesProvider.setConfiguratorImpl(address(configurator));

    configurator = Configurator(addressesProvider.getConfigurator());
    router = Router(payable(addressesProvider.getRouter()));

    accountImpl = new AccountV1(address(addressesProvider));
    Proxy accountProxy = new Proxy(address(addressesProvider));

    addressesProvider.setAddress(bytes32("ACCOUNT"), address(accountImpl));
    addressesProvider.setAddress(bytes32("TREASURY"), TREASURY);
    addressesProvider.setAddress(bytes32("ACCOUNT_PROXY"), address(accountProxy));
    vm.stopPrank();

    vm.prank(CONNECTOR_ADMIN);
    configurator.addConnectors(_names, _connectors);

    vm.prank(VAULT_ADMIN);
    configurator.addVaults(_vaults);

    vm.prank(ROUTER_ADMIN);
    configurator.setFee(3);
  }
}

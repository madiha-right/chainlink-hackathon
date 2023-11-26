// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";

import { IRouter } from "contracts/interfaces/IRouter.sol";

import { Router } from "contracts/Router.sol";
import { Connectors } from "contracts/Connectors.sol";
import { ACLManager } from "contracts/ACLManager.sol";
import { Configurator } from "contracts/Configurator.sol";
import { AddressesProvider } from "contracts/AddressesProvider.sol";

import { Tokens } from "../../../utils/tokens.sol";

contract RouterV2 is Router {
  uint256 public constant ROUTER_REVISION_2 = 0x2;

  constructor(IAddressesProvider _provider) Router(_provider) { }

  function getRevision() internal pure override returns (uint256) {
    return ROUTER_REVISION_2;
  }
}

contract TestRouter is Tokens {
  Router router;
  Connectors connectors;
  Configurator configurator;
  ACLManager aclManager;
  AddressesProvider addressesProvider;

  address testAddress;

  function setUp() public {
    string memory url = vm.rpcUrl("mainnet");
    uint256 forkId = vm.createFork(url);
    vm.selectFork(forkId);

    addressesProvider = new AddressesProvider(address(this));
    addressesProvider.setAddress(bytes32("ACL_ADMIN"), address(this));

    aclManager = new ACLManager(IAddressesProvider(address(addressesProvider)));
    connectors = new Connectors(address(addressesProvider));

    aclManager.addConnectorAdmin(address(this));
    aclManager.addRouterAdmin(address(this));

    addressesProvider.setAddress(bytes32("ACL_MANAGER"), address(aclManager));
    addressesProvider.setAddress(bytes32("CONNECTORS"), address(connectors));

    configurator = new Configurator();

    router = new Router(IAddressesProvider(address(addressesProvider)));
    addressesProvider.setRouterImpl(address(router));
    addressesProvider.setConfiguratorImpl(address(configurator));

    configurator = Configurator(addressesProvider.getConfigurator());
    router = Router(payable(addressesProvider.getRouter()));
  }

  function test_initialize() public {
    configurator.setFee(100);

    RouterV2 routerV2 = new RouterV2(IAddressesProvider(address(addressesProvider)));
    addressesProvider.setRouterImpl(address(routerV2));

    uint256 fee = router.fee();
    assertEq(fee, 50);
  }

  receive() external payable { }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";

import { Router } from "contracts/Router.sol";
import { Connectors } from "contracts/Connectors.sol";
import { Vaults } from "contracts/Vaults.sol";
import { Vault } from "contracts/Vault.sol";
import { ACLManager } from "contracts/ACLManager.sol";
import { Configurator } from "contracts/Configurator.sol";
import { AddressesProvider } from "contracts/AddressesProvider.sol";

import { Tokens } from "utils/Tokens.sol";

contract RouterV2 is Router {
  uint256 public constant ROUTER_REVISION_2 = 0x2;

  constructor(IAddressesProvider _provider) Router(_provider) { }

  function getRevision() internal pure override returns (uint256) {
    return ROUTER_REVISION_2;
  }
}

contract TestRouter is Tokens, Test {
  Router router;
  Connectors connectors;
  Vaults vaults;
  Configurator configurator;
  ACLManager aclManager;
  AddressesProvider addressesProvider;
  Vault daiVault;

  address testAddress;

  function setUp() public {
    string memory url = vm.rpcUrl("mainnet");
    uint256 forkId = vm.createFork(url);
    vm.selectFork(forkId);

    addressesProvider = new AddressesProvider(address(this));
    addressesProvider.setAddress(bytes32("ACL_ADMIN"), address(this));

    aclManager = new ACLManager(IAddressesProvider(address(addressesProvider)));
    connectors = new Connectors(address(addressesProvider));
    vaults = new Vaults(address(addressesProvider));

    aclManager.addConnectorAdmin(address(this));
    aclManager.addRouterAdmin(address(this));
    aclManager.addVaultAdmin(address(this));

    addressesProvider.setAddress(bytes32("ACL_MANAGER"), address(aclManager));
    addressesProvider.setAddress(bytes32("CONNECTORS"), address(connectors));
    addressesProvider.setAddress(bytes32("VAULTS"), address(vaults));

    configurator = new Configurator();

    router = new Router(IAddressesProvider(address(addressesProvider)));
    addressesProvider.setRouterImpl(address(router));
    addressesProvider.setConfiguratorImpl(address(configurator));

    configurator = Configurator(addressesProvider.getConfigurator());
    router = Router(payable(addressesProvider.getRouter()));

    daiVault = new Vault(IERC20(getToken('dai')), 'vault dai', 'vDAI');

    address[] memory addresses = new address[](1);
    addresses[0] = address(daiVault);

    configurator.addVaults(addresses);
  }

  function test_initialize() public {
    configurator.setFee(100);

    RouterV2 routerV2 = new RouterV2(IAddressesProvider(address(addressesProvider)));
    addressesProvider.setRouterImpl(address(routerV2));

    uint256 fee = router.fee();
    assertEq(fee, 50);
  }

  function test_delegate() public {
    deal(getToken("dai"), address(this), 1000 * 1e18);

    IERC20(getToken("dai")).approve(address(router), 1000 * 1e18);
    router.delegate(address(getToken("dai")), 1000 * 1e18);

    uint256 balance = router.balances(address(getToken("dai")), address(this));

    assertEq(balance, 1000 * 1e18);
    assertEq(daiVault.totalAssets(), 1000 * 1e18);
  }

  function test_undelegate() public {
    uint256 amount = 1000 * 1e18;

    deal(getToken("dai"), address(this), amount);

    IERC20(getToken("dai")).approve(address(router), amount);
    router.delegate(getToken("dai"), amount);

    assertEq(router.balances(getToken("dai"), address(this)), amount);
    assertEq(daiVault.totalAssets(), amount);

    router.undelegate(address(getToken("dai")), amount);

    assertEq(router.balances(getToken("dai"), address(this)), 0);
    assertEq(daiVault.totalAssets(), 0);
  }

  receive() external payable { }
}

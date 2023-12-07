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

contract DeployCore is Tokens, Script {
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
    _names[0] = "sDAI";
    _names[1] = "AaveV2";
    _names[2] = "AaveV3";
    _names[3] = "CompoundV2";
    _names[4] = "Spark";

    address[] memory _connectors = new address[](5);
    _connectors[0] = 0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496; // sDAI connector
    _connectors[1] = 0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3; // aave v2 connector
    _connectors[2] = 0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76; // aave v3 connector
    _connectors[3] = 0x50EEf481cae4250d252Ae577A09bF514f224C6C4; // compound v2 connector
    _connectors[4] = 0x62c20Aa1e0272312BC100b4e23B4DC1Ed96dD7D1; // spark connector

    address[] memory _vaults = new address[](2);
    _vaults[0] = 0xad216Ca69843e97062E18bDa77b5CE06626c3285; // weth vault
    _vaults[1] = 0xcC2E06680A4E8f6B71030c684852A53D5200CD7C; // dai vault

    configurator.addConnectors(_names, _connectors);
    configurator.addVaults(_vaults);
    configurator.setFee(3);
  }
}

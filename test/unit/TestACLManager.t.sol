// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { Errors } from "contracts/lib/Errors.sol";
import { ACLManager } from "contracts/ACLManager.sol";
import { AddressesProvider } from "contracts/AddressesProvider.sol";

contract ConnectorImpl {
  string public constant name = "ConnectorImpl";
}

contract TestACLManager is Test {
  ACLManager aclManager;

  address testAddress;

  function setUp() public {
    AddressesProvider addressesProvider = new AddressesProvider(address(this));
    addressesProvider.setAddress(bytes32("ACL_ADMIN"), address(this));

    aclManager = new ACLManager(addressesProvider);
  }

  // Main identifiers
  function test_setRoleAdmin() public {
    aclManager.setRoleAdmin(bytes32("ROUTER_ADMIN_ROLE"), bytes32("DEFAULT_ADMIN_ROLE"));
    assertEq(aclManager.getRoleAdmin(bytes32("ROUTER_ADMIN_ROLE")), bytes32("DEFAULT_ADMIN_ROLE"));
  }

  function test_addRouterAdmin() public {
    aclManager.addRouterAdmin(address(this));
    assertTrue(aclManager.isRouterAdmin(address(this)));
  }

  function test_removeRouterAdmin() public {
    aclManager.removeRouterAdmin(address(this));
    assertTrue(!aclManager.isRouterAdmin(address(this)));
  }

  function test_addConnectorAdmin() public {
    aclManager.addConnectorAdmin(address(this));
    assertTrue(aclManager.isConnectorAdmin(address(this)));
  }

  function test_removeConnectorAdmin() public {
    aclManager.removeConnectorAdmin(address(this));
    assertTrue(!aclManager.isConnectorAdmin(address(this)));
  }

  function test_addVaultAdmin() public {
    aclManager.addVaultAdmin(address(this));
    assertTrue(aclManager.isVaultAdmin(address(this)));
  }

  function test_removeVaultAdmin() public {
    aclManager.removeVaultAdmin(address(this));
    assertTrue(!aclManager.isVaultAdmin(address(this)));
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { VersionedInitializable } from "../../lib/upgradeability/VersionedInitializable.sol";

import { IAddressesProvider } from "../../src/interfaces/IAddressesProvider.sol";

import { Errors } from "../../src/lib/Errors.sol";

import { ACLManager } from "../../src/ACLManager.sol";
import { AddressesProvider } from "../../src/AddressesProvider.sol";

contract DummyContract is VersionedInitializable {
  uint256 public count = 1;

  uint256 public constant DUMMY_REVISION = 0x1;

  function initialize(address provider) external initializer { }

  function getRevision() internal pure virtual override returns (uint256) {
    return DUMMY_REVISION;
  }
}

contract DummyContract2 is VersionedInitializable {
  uint256 public count = 1;

  uint256 public constant DUMMY_REVISION = 0x2;

  function initialize(address provider) external initializer { }

  function getRevision() internal pure virtual override returns (uint256) {
    return DUMMY_REVISION;
  }
}

contract TestAddressesProvider is Test {
  AddressesProvider addressesProvider;

  address testAddress;

  function setUp() public {
    addressesProvider = new AddressesProvider(address(this));
    testAddress = address(new DummyContract());
  }

  function test_setAddress_Configurator() public {
    addressesProvider.setConfiguratorImpl(testAddress);
    assertTrue(addressesProvider.getConfigurator() != address(0));
  }

  function test_updateAddress_Configurator() public {
    addressesProvider.setConfiguratorImpl(testAddress);
    assertTrue(addressesProvider.getConfigurator() != address(0));

    address newTestContract = address(new DummyContract2());

    addressesProvider.setConfiguratorImpl(newTestContract);
    assertTrue(addressesProvider.getConfigurator() != address(0) && addressesProvider.getConfigurator() != testAddress);
  }

  function test_setAddress_Router() public {
    addressesProvider.setRouterImpl(testAddress);
    assertTrue(addressesProvider.getRouter() != address(0));
  }

  function test_setAddress_Account() public {
    addressesProvider.setAddress(bytes32("ACCOUNT"), testAddress);
    assertEq(addressesProvider.getAccountImpl(), testAddress);
  }

  function test_setAddress_Treasury() public {
    addressesProvider.setAddress(bytes32("TREASURY"), testAddress);
    assertEq(addressesProvider.getTreasury(), testAddress);
  }

  function test_setAddress_Connectors() public {
    addressesProvider.setAddress(bytes32("CONNECTORS"), testAddress);
    assertEq(addressesProvider.getConnectors(), testAddress);
  }

  function test_setAddress_Vaults() public {
    addressesProvider.setAddress(bytes32("VAULTS"), testAddress);
    assertEq(addressesProvider.getVaults(), testAddress);
  }

  function test_setAddress_AccountProxy() public {
    addressesProvider.setAddress(bytes32("ACCOUNT_PROXY"), testAddress);
    assertEq(addressesProvider.getAccountProxy(), testAddress);
  }

  receive() external payable { }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Test, console2 } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { Constants } from "./helpers/Constants.sol";
import { Errors } from "./helpers/Errors.sol";
import { Vault } from "../src/Vault.sol";

contract TestBase is Test, Constants, Errors {
  Vault DAI_VAULT;

  constructor() {
    setUpBase();
  }

  function setUpBase() public {
    DAI_VAULT = new Vault(IERC20(DAI), 'vault DAI', 'vDAI', address(this));
  }
}

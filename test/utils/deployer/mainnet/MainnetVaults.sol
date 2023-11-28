// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Vault } from "contracts/Vault.sol";

contract DeployMainnetVaults {
  Vault public wethVault;
  Vault public daiVault;

  function deployVaults() public returns (address[] memory) {
    _deployVaults();

    address[] memory vaults = new address[](2);
    vaults[0] = address(wethVault);
    vaults[1] = address(daiVault);

    return vaults;
  }

  function _deployVaults() private {
    wethVault = new Vault(IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), 'vault WETH', 'vWETH');
    daiVault = new Vault(IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F), 'vault DAI', 'vDAI');
  }
}

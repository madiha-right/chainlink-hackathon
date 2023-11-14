// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IVault } from "./interfaces/IVault.sol";

contract Vault is IVault, ERC4626, Ownable {
  constructor(IERC20 asset, string memory name, string memory symbol, address initialOwner)
    ERC4626(asset)
    ERC20(name, symbol)
    Ownable(initialOwner)
  { }

  /**
   * @dev See {IERC4626-deposit}.
   */
  function deposit(uint256 amount, address receiver) public override(ERC4626, IVault) onlyOwner returns (uint256) {
    return super.deposit(amount, receiver);
  }

  /**
   * @dev See {IERC4626-mint}.
   */
  function mint(uint256 shares, address receiver) public override(ERC4626, IVault) onlyOwner returns (uint256) {
    return super.mint(shares, receiver);
  }

  /**
   * @dev See {IERC4626-withdraw}.
   */
  function withdraw(uint256 amount, address receiver, address owner)
    public
    override(ERC4626, IVault)
    onlyOwner
    returns (uint256)
  {
    return super.withdraw(amount, receiver, owner);
  }

  /**
   * @dev See {IERC4626-redeem}.
   */
  function redeem(uint256 shares, address receiver, address owner)
    public
    override(ERC4626, IVault)
    onlyOwner
    returns (uint256)
  {
    return super.redeem(shares, receiver, owner);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IZapper } from "../interfaces/IZapper.sol";
import { IConnector } from "../interfaces/IConnector.sol";
import { ICTokenERC20 } from "../interfaces/compound-v2/ICTokenERC20.sol";
import { IComptroller } from "../interfaces/compound-v2/IComptroller.sol";

/**
 * @title CompoundV2Connector
 * @dev This contract facilitates interactions with Compound V2 protocol for deposit, withdrawal, and querying underlying assets.
 */
contract CompoundV2Connector is IConnector {
  using SafeERC20 for IERC20;

  IZapper public immutable Y;

  modifier onlyY() {
    require(msg.sender == address(Y), "caller must be zapper");
    _;
  }

  constructor(IZapper y) {
    Y = y;
  }

  /**
   * @dev See {IConnector-deposit}.
   */
  function deposit(address asset, uint256 amount, address onBehalfOf, address yieldSource) external onlyY {
    // approve underlying asset to the yield source
    if (IERC20(asset).allowance(address(this), yieldSource) == 0) {
      IERC20(asset).forceApprove(yieldSource, type(uint256).max);
    }
    // need amount to send the underlying asset to the CToken of compound v2
    ICTokenERC20(yieldSource).mint(amount);

    IComptroller comptroller = IComptroller(ICTokenERC20(yieldSource).comptroller());
    address[] memory cTokens = new address[](1);
    cTokens[0] = address(yieldSource);

    uint256[] memory errors = comptroller.enterMarkets(cTokens);

    require(errors[0] == 0, "Entering market failed");

    // transfer cToken to the Y
    if (onBehalfOf != address(this)) {
      IERC20(yieldSource).safeTransfer(onBehalfOf, amount);
    }
  }

  /**
   * @dev See {IConnector-borrow}.
   */
  function borrow(address asset, uint256 amount, address onBehalfOf, address yieldSource) external {
    IERC20(asset).safeTransfer(onBehalfOf, amount);
  }

  /**
   * @dev See {IConnector-withdraw}.
   */
  function withdraw(address asset, uint256 amount, address to, address yieldSource) external onlyY {
    ICTokenERC20(yieldSource).redeemUnderlying(amount);
    // transfer underlying asset to the Zapper
    IERC20(asset).safeTransfer(to, amount);
  }

  /**
   * @dev See {IConnector-getUnderlyingAsset}.
   */
  function getUnderlyingAsset(address asset, address yieldSource) external view returns (address) {
    return ICTokenERC20(yieldSource).underlying();
  }

  /**
   * @dev See {IConnector-getYieldSource}.
   */
  function getYieldSource(address asset) external pure returns (address) {
    return asset;
  }
}

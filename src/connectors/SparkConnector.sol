// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IZapper } from "../interfaces/IZapper.sol";
import { IConnector } from "../interfaces/IConnector.sol";
import { ILendingPool } from "../interfaces/aave-v2/ILendingPool.sol";
import { IAToken } from "../interfaces/aave-v2/IAToken.sol";

/**
 * @title SparkConnector
 * @dev This contract facilitates interactions with Spark protocol for deposit, withdrawal, and querying underlying assets.
 */
abstract contract SparkConnector is IConnector {
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

    ILendingPool(yieldSource).deposit(asset, amount, onBehalfOf, 0);
  }

  /**
   * @dev See {IConnector-borrow}.
   */
  function borrow(address asset, uint256 amount, address onBehalfOf, address yieldSource) external onlyY {
    ILendingPool(yieldSource).borrow(asset, amount, 2, 0, address(this));
    IERC20(asset).safeTransfer(onBehalfOf, amount);
  }

  /**
   * @dev See {IConnector-withdraw}.
   */
  function withdraw(address asset, uint256 amount, address to, address yieldSource) external onlyY {
    ILendingPool(yieldSource).withdraw(asset, amount, to);
  }

  /**
   * @dev See {IConnector-getUnderlyingAsset}.
   */
  function getUnderlyingAsset(address asset, address yieldSource) external view returns (address) {
    return IAToken(asset).UNDERLYING_ASSET_ADDRESS();
  }

  /**
   * @dev See {IConnector-getYieldSource}.
   */
  function getYieldSource(address asset) external view returns (address) {
    return address(IAToken(asset).POOL());
  }
}

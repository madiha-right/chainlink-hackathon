// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library DataTypes {
  struct Position {
    address account;
    address debtAsset;
    address collateralAsset;
    uint256 collateralAmount;
    uint256 borrowAmount;
  }
}

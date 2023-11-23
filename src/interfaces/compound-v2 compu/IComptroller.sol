// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.20;

interface IComptroller {
  function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
}

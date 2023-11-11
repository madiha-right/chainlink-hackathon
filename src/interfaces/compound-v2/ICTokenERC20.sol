// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

interface ICTokenERC20 {
  function mint(uint mintAmount) external virtual returns (uint);

  function redeem(uint redeemTokens) external virtual returns (uint);

  function redeemUnderlying(uint redeemAmount) external virtual returns (uint);

  function borrow(uint borrowAmount) external virtual returns (uint);

  function repayBorrow(uint repayAmount) external virtual returns (uint);

  function repayBorrowBehalf(address borrower, uint repayAmount) external virtual returns (uint);

  function balanceOf(address owner) external view virtual returns (uint256);

  function borrowBalanceStored(address account) external view virtual returns (uint);

  function exchangeRateStored() external view virtual returns (uint);

  // function liquidateBorrow(
  //   address borrower,
  //   uint repayAmount,
  //   CTokenInterface cTokenCollateral
  // ) external virtual returns (uint);

  // function sweepToken(EIP20NonStandardInterface token) external virtual;

  function underlying() external view returns (address);

  function comptroller() external view returns (address);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.20;

interface ICTokenERC20 {
  function mint(uint256 mintAmount) external returns (uint256);

  function redeem(uint256 redeemTokens) external returns (uint256);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

  function borrow(uint256 borrowAmount) external returns (uint256);

  function repayBorrow(uint256 repayAmount) external returns (uint256);

  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function borrowBalanceStored(address account) external view returns (uint256);

  function exchangeRateStored() external view returns (uint256);

  // function liquidateBorrow(
  //   address borrower,
  //   uint repayAmount,
  //   CTokenInterface cTokenCollateral
  // ) external  returns (uint);

  // function sweepToken(EIP20NonStandardInterface token) external ;

  function underlying() external view returns (address);

  function comptroller() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ICompoundV2Connector } from "../../interfaces/connectors/ICompoundV2Connector.sol";
import { CErc20Interface } from "../../interfaces/external/compound-v2/CTokenInterfaces.sol";
import { ComptrollerInterface } from "../../interfaces/external/compound-v2/ComptrollerInterface.sol";

import { Errors } from "../../lib/Errors.sol";

contract CompoundV2Connector is ICompoundV2Connector {
  using SafeERC20 for IERC20;

  /* ============ Constants ============ */

  /**
   * @dev Compound COMPTROLLER
   */
  ComptrollerInterface internal constant COMPTROLLER = ComptrollerInterface(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

  /**
   * @dev Connector name
   */
  string public constant NAME = "CompoundV2";

  /* ============ External Functions ============ */

  function deposit(address token, uint256 amount) external {
    CErc20Interface cToken = getCToken(token);

    _enterMarket(address(cToken));

    amount = amount == type(uint256).max ? IERC20(token).balanceOf(address(this)) : amount;
    IERC20(token).forceApprove(address(cToken), amount);

    CErc20Interface(cToken).mint(amount);
  }

  function withdraw(address token, uint256 amount) external {
    CErc20Interface cToken = getCToken(token);

    if (amount == type(uint256).max) {
      cToken.redeem(cToken.balanceOf(address(this)));
    } else {
      cToken.redeemUnderlying(amount);
    }
  }

  function borrow(address token, uint256 amount) external {
    CErc20Interface cToken = getCToken(token);

    _enterMarket(address(cToken));
    CErc20Interface(cToken).borrow(amount);
  }

  function payback(address token, uint256 amount) external {
    CErc20Interface cToken = getCToken(token);

    amount = amount == type(uint256).max ? cToken.borrowBalanceCurrent(address(this)) : amount;

    if (IERC20(token).balanceOf(address(this)) < amount) revert Errors.InsufficientBalance();

    IERC20(token).forceApprove(address(cToken), amount);
    cToken.repayBorrow(amount);
  }

  /* ============ Public Functions ============ */

  function borrowBalanceOf(address token, address user) public returns (uint256) {
    CErc20Interface cToken = getCToken(token);
    return cToken.borrowBalanceCurrent(user);
  }

  function collateralBalanceOf(address token, address user) public returns (uint256) {
    CErc20Interface cToken = getCToken(token);
    return cToken.balanceOfUnderlying(user);
  }

  function getCToken(address token) public pure returns (CErc20Interface) {
    if (token == 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9) {
      // AAVE
      return CErc20Interface(0xe65cdB6479BaC1e22340E4E755fAE7E509EcD06c);
    }
    if (token == 0x0D8775F648430679A709E98d2b0Cb6250d2887EF) {
      // BAT
      return CErc20Interface(0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E);
    }
    if (token == 0xc00e94Cb662C3520282E6f5717214004A7f26888) {
      return CErc20Interface(0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4);
    }
    if (token == 0x6B175474E89094C44Da98b954EedeAC495271d0F) {
      // DAI
      return CErc20Interface(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    }
    if (token == 0x956F47F50A910163D8BF957Cf5846D573E7f87CA) {
      // FEI
      return CErc20Interface(0x7713DD9Ca933848F6819F38B8352D9A15EA73F67);
    }
    if (token == 0x514910771AF9Ca656af840dff83E8264EcF986CA) {
      // LINK
      return CErc20Interface(0xFAce851a4921ce59e912d19329929CE6da6EB0c7);
    }
    if (token == 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2) {
      // MAKER
      return CErc20Interface(0x95b4eF2869eBD94BEb4eEE400a99824BF5DC325b);
    }
    if (token == 0x1985365e9f78359a9B6AD760e32412f4a445E862) {
      // REP
      return CErc20Interface(0x158079Ee67Fce2f58472A96584A73C7Ab9AC95c1);
    }
    if (token == 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359) {
      // SAI
      return CErc20Interface(0xF5DCe57282A584D2746FaF1593d3121Fcac444dC);
    }
    if (token == 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2) {
      // SUSHI
      return CErc20Interface(0x4B0181102A0112A2ef11AbEE5563bb4a3176c9d7);
    }
    if (token == 0x0000000000085d4780B73119b644AE5ecd22b376) {
      // TUSD
      return CErc20Interface(0x12392F67bdf24faE0AF363c24aC620a2f67DAd86);
    }
    if (token == 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984) {
      // UNI
      return CErc20Interface(0x35A18000230DA775CAc24873d00Ff85BccdeD550);
    }
    if (token == 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) {
      // USDC
      return CErc20Interface(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    }
    if (token == 0x8E870D67F660D95d5be530380D0eC0bd388289E1) {
      // USDP
      return CErc20Interface(0x041171993284df560249B57358F931D9eB7b925D);
    }
    if (token == 0xdAC17F958D2ee523a2206206994597C13D831ec7) {
      // USDT
      return CErc20Interface(0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9);
    }
    if (token == 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599) {
      // WBTC
      return CErc20Interface(0xccF4429DB6322D5C611ee964527D42E5d685DD6a);
    }
    if (token == 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e) {
      // YFI
      return CErc20Interface(0x80a2AE356fc9ef4305676f7a3E2Ed04e12C33946);
    }
    if (token == 0xE41d2489571d322189246DaFA5ebDe1F4699F498) {
      // ZRX
      return CErc20Interface(0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407);
    }
    // NOTE: revert ETH as well
    revert("Unsupported token");
  }

  /* ============ Internal Functions ============ */

  /**
   * @dev Enter compound market
   */
  function _enterMarket(address cToken) internal {
    address[] memory markets = COMPTROLLER.getAssetsIn(address(this));
    bool isEntered = false;
    for (uint256 i = 0; i < markets.length; i++) {
      if (markets[i] == cToken) {
        isEntered = true;
      }
    }
    if (!isEntered) {
      address[] memory toEnter = new address[](1);
      toEnter[0] = cToken;
      COMPTROLLER.enterMarkets(toEnter);
    }
  }
}

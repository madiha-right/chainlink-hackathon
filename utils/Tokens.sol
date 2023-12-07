// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Tokens {
  function getToken(string memory _name) public view returns (address) {
    uint256 chainId = getChainID();

    if (chainId == 1) {
      if (compare(_name, "dai")) {
        return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
      } else if (compare(_name, "usdc")) {
        return 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
      } else if (compare(_name, "eth")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "weth")) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
      } else if (compare(_name, "usdt")) {
        return 0xdAC17F958D2ee523a2206206994597C13D831ec7;
      }
    } else if (chainId == 137) {
      if (compare(_name, "dai")) {
        return 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
      } else if (compare(_name, "usdc")) {
        return 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
      } else if (compare(_name, "matic")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "weth")) {
        return 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
      } else if (compare(_name, "usdt")) {
        return 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
      }
    } else if (chainId == 56) {
      if (compare(_name, "dai")) {
        return 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
      } else if (compare(_name, "usdc")) {
        return 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
      } else if (compare(_name, "bnb")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "usdt")) {
        return 0x55d398326f99059fF775485246999027B3197955;
      } else if (compare(_name, "wbnb")) {
        return 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
      } else if (compare(_name, "busd")) {
        return 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
      }
    } else if (chainId == 11155111) {
      // sepolia
      if (compare(_name, "dai")) {
        return 0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357;
      } else if (compare(_name, "usdc")) {
        return 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
      } else if (compare(_name, "matic")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "weth")) {
        return 0xC558DBdd856501FCd9aaF1E62eae57A9F0629a3c;
      } else if (compare(_name, "usdt")) {
        return 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0;
      }
    } else if (chainId == 43113) {
      // fuji
      if (compare(_name, "dai")) {
        return 0x676bD5B5d0955925aeCe653C50426940c58036c8;
      } else if (compare(_name, "usdc")) {
        return 0xCaC7Ffa82c0f43EBB0FC11FCd32123EcA46626cf;
      } else if (compare(_name, "matic")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "weth")) {
        return 0xf97b6C636167B529B6f1D729Bd9bC0e2Bd491848;
      } else if (compare(_name, "usdt")) {
        return 0xBDE7fbbb1DC89E74B73C54Ad911A1C9685caCD83;
      }
    } else if (chainId == 1442) {
      // polygon zkevm testnet
      if (compare(_name, "dai")) {
        return 0x636fa8e3B7555b2c6f2A1A82f7F58f816ccF0Af2;
      } else if (compare(_name, "usdc")) {
        return 0xBD664D0b9D368599203a42CbE5eFBA2520A332E6;
      } else if (compare(_name, "matic")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "weth")) {
        return 0x4F062A3EAeC3730560aB89b5CE5aC0ab2C5517aE;
      } else if (compare(_name, "usdt")) {
        return 0xBDE7fbbb1DC89E74B73C54Ad911A1C9685caCD83;
      }
    } else if (chainId == 31337) {
      if (compare(_name, "dai")) {
        return 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
      } else if (compare(_name, "usdc")) {
        return 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
      } else if (compare(_name, "matic")) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
      } else if (compare(_name, "weth")) {
        return 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
      } else if (compare(_name, "usdt")) {
        return 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
      }
    }
    revert("dont have token");
  }

  function getCcipInfo() public view returns (address, uint64, address) {
    uint256 chainId = getChainID();

    if (chainId == 1) {
      // CCIP Router address, Destination chain selector, LINK address
      return
        (0xE561d5E02207fb5eB32cca20a699E0d8919a1476, 5009297550715157269, 0x514910771AF9Ca656af840dff83E8264EcF986CA);
    } else if (chainId == 11155111) {
      // sepolia
      return
        (0xD0daae2231E9CB96b94C8512223533293C3693Bf, 16015286601757825753, 0x779877A7B0D9E8603169DdbD7836e478b4624789);
    } else if (chainId == 43113) {
      // fuji
      return
        (0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, 14767482510784806043, 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846);
    } else if (chainId == 1442) {
      // polygon zkevm testnet
      return (0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, 666, 0xbC2668a14dCD0343bDf1e21F7E4C5C6c435973A7);
    } else if (chainId == 31337) {
      // local
      return
        (0xE561d5E02207fb5eB32cca20a699E0d8919a1476, 5009297550715157269, 0x514910771AF9Ca656af840dff83E8264EcF986CA);
    }
    revert("dont have ccip info");
  }

  function compare(string memory str1, string memory str2) public pure returns (bool) {
    if (bytes(str1).length != bytes(str2).length) {
      return false;
    }
    return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
  }

  function getChainID() public view returns (uint256) {
    uint256 id;
    assembly {
      id := chainid()
    }
    return id;
  }
}

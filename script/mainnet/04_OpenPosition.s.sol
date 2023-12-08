// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { console } from "forge-std/Console.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { DataTypes } from "contracts/lib/DataTypes.sol";

import { UniversalPosition } from "./utils/UniversalPosition.s.sol";

contract OpenPosition is UniversalPosition {
  function run() public {
    uint256 pk = vm.envUint("PRIVATE_KEY");
    address account = vm.addr(pk);

    vm.startBroadcast(pk);

    // (, uint64 destChainSelector,) = getCcipInfo();
    // address ccip = ADDRESSES_PROVIDER.getCcip();
    DataTypes.Position memory position = DataTypes.Position(
      account, getToken("weth"), getToken("dai"), 0.1 ether, 1000 ether, SDAI_CONNECTOR.NAME(), 0, address(0)
    );

    (, uint256 index) = openPosition(position, address(SDAI_CONNECTOR), address(AAVE_V3_CONNECTOR));

    console.log("position index", index);

    vm.stopBroadcast();
  }

  function _getOpenConnectorDatas(DataTypes.Position memory position) internal pure override returns (bytes[] memory) {
    bytes[] memory datas = new bytes[](3);
    datas[0] = _getDepositSDAICallData(position.collateralAmount);
    datas[1] = _getDepositCallData(position.collateralAsset, position.collateralAmount);
    datas[2] = _getBorrowCallData(position.debtAsset, position.borrowAmount);
    return datas;
  }

  function _getDepositCallData(address token, uint256 amount) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(AAVE_V3_CONNECTOR.deposit.selector, token, amount);
  }

  function _getBorrowCallData(address token, uint256 amount) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(AAVE_V3_CONNECTOR.borrow.selector, token, amount, RATE_TYPE);
  }

  function _getDepositSDAICallData(uint256 amount) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(SDAI_CONNECTOR.deposit.selector, amount);
  }
}

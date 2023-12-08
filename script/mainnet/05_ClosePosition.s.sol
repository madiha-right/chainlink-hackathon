// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { console } from "forge-std/Console.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IRouter } from "contracts/interfaces/IRouter.sol";
import { DataTypes } from "contracts/lib/DataTypes.sol";

import { UniversalPosition } from "./utils/UniversalPosition.s.sol";

contract ClosePosition is UniversalPosition {
  uint256 constant INDEX_POSITION = 2;

  function run() public {
    uint256 pk = vm.envUint("PRIVATE_KEY");
    address account = vm.addr(pk);

    vm.startBroadcast(pk);

    // (, uint64 destChainSelector,) = getCcipInfo();
    // address ccip = ADDRESSES_PROVIDER.getCcip();

    closePosition(account, INDEX_POSITION, address(SDAI_CONNECTOR), address(AAVE_V3_CONNECTOR));

    vm.stopBroadcast();
  }

  // function getWrappedETH() public {
  //   WETH(getToken("weth")).deposit{ value: 1 ether }();
  // }

  function _getCloseConnectorDatas(DataTypes.Position memory position, bytes32 positionKey, address user)
    internal
    view
    override
    returns (bytes[] memory)
  {
    address router = ADDRESSES_PROVIDER.getRouter();
    (,,, uint256 borrowAmount, uint256 collateralAmount,,,) = IRouter(router).positions(positionKey);

    bytes[] memory datas = new bytes[](3);

    datas[0] = _getRedeemCallData(user);
    datas[1] = _getPaybackCallData(position.debtAsset, borrowAmount);
    datas[2] = _getWithdrawCallData(position.collateralAsset, collateralAmount);
    return datas;
  }

  function _getPaybackCallData(address token, uint256 amount) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(AAVE_V3_CONNECTOR.payback.selector, token, amount, RATE_TYPE);
  }

  function _getWithdrawCallData(address token, uint256 amount) internal pure returns (bytes memory) {
    return abi.encodeWithSelector(AAVE_V3_CONNECTOR.withdraw.selector, token, amount);
  }

  function _getRedeemCallData(address user) internal view returns (bytes memory) {
    // sDAI
    uint256 shares = SDAI_CONNECTOR.getShares(user);
    return abi.encodeWithSelector(SDAI_CONNECTOR.redeem.selector, shares);
  }
}

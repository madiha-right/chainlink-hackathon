// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { DataTypes } from "contracts/lib/DataTypes.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";

import { UniversalPosition } from "../UniversalPosition.sol";
import { DeployMainnetContracts } from "../../../utils/deployer/mainnet/mainnet.sol";

contract PositionAaveV2Mainnet is UniversalPosition, DeployMainnetContracts {
  // aave v2 connector integration
  uint256 constant RATE_TYPE = 2;

  address public user = makeAddr("user");

  function test_OpenPosition_ClosePosition() public {
    (DataTypes.Position memory position, uint256 index) = openPosition(
      user, getToken("weth"), getToken("dai"), 0.1 ether, 1000 ether, address(sDAIConnector), address(aaveV2Connector)
    );

    closePosition(user, index, address(sDAIConnector), address(aaveV2Connector), position);
  }

  function test_OpenAndClose_TwoPosition() public {
    (DataTypes.Position memory position1, uint256 index1) = openPosition(
      user, getToken("weth"), getToken("dai"), 0.1 ether, 1000 ether, address(sDAIConnector), address(aaveV2Connector)
    );

    (DataTypes.Position memory position2, uint256 index2) = openPosition(
      user, getToken("weth"), getToken("dai"), 0.1 ether, 1000 ether, address(sDAIConnector), address(aaveV2Connector)
    );

    closePosition(user, index1, address(sDAIConnector), address(aaveV2Connector), position1);
    closePosition(user, index2, address(sDAIConnector), address(aaveV2Connector), position2);
  }

  function _getOpenConnectorDatas(DataTypes.Position memory position) internal view override returns (bytes[] memory) {
    bytes[] memory datas = new bytes[](3);
    datas[0] = _getDepositSDAICallData(position.collateralAmount);
    datas[1] = _getDepositCallData(position.collateralAsset, position.collateralAmount);
    datas[2] = _getBorrowCallData(position.debtAsset, position.borrowAmount);
    return datas;
  }

  function _getCloseConnectorDatas(DataTypes.Position memory position, bytes32 positionKey)
    internal
    view
    override
    returns (bytes[] memory)
  {
    (,,, uint256 borrowAmount, uint256 collateralAmount,) = router.positions(positionKey);

    bytes[] memory datas = new bytes[](3);
    datas[0] = _getPaybackCallData(position.debtAsset, borrowAmount);
    datas[1] = _getWithdrawCallData(position.collateralAsset, collateralAmount);
    datas[2] = _getRedeemCallData(position.account);
    return datas;
  }

  function _getDepositCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.deposit.selector, token, amount);
  }

  function _getBorrowCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.borrow.selector, token, amount, RATE_TYPE);
  }

  function _getPaybackCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.payback.selector, token, amount, RATE_TYPE);
  }

  function _getWithdrawCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(aaveV2Connector.withdraw.selector, token, amount);
  }

  function _getDepositSDAICallData(uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sDAIConnector.deposit.selector, amount);
  }

  function _getRedeemCallData(address _user) internal view returns (bytes memory) {
    // sDAI
    uint256 shares = IERC20(0x83F20F44975D03b1b09e64809B757c47f942BEeA).balanceOf(_user);
    return abi.encodeWithSelector(sDAIConnector.redeem.selector, shares);
  }
}

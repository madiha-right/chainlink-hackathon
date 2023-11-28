// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { DataTypes } from "contracts/lib/DataTypes.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";

import { UniversalPosition } from "../UniversalPosition.sol";
import { DeployMainnetContracts } from "../../../utils/deployer/mainnet/mainnet.sol";

contract PositionSparkMainnet is UniversalPosition, DeployMainnetContracts {
  // spark connector integration
  uint256 constant RATE_TYPE = 2;

  address public user = makeAddr("user");

  function test_OpenPosition_ClosePosition() public {
    (DataTypes.Position memory position, uint256 index) = openPosition(
      user, getToken("dai"), getToken("weth"), 100 * 1e18, 1 ether, address(aaveV3Connector), address(sparkConnector)
    );

    closePosition(user, index, address(aaveV3Connector), address(sparkConnector), position);
  }

  function test_OpenAndClose_TwoPosition() public {
    (DataTypes.Position memory position1, uint256 index1) = openPosition(
      user, getToken("dai"), getToken("weth"), 100 * 1e18, 1 ether, address(aaveV3Connector), address(sparkConnector)
    );

    (DataTypes.Position memory position2, uint256 index2) = openPosition(
      user, getToken("dai"), getToken("weth"), 100 * 1e18, 1 ether, address(aaveV3Connector), address(sparkConnector)
    );

    closePosition(user, index1, address(aaveV3Connector), address(sparkConnector), position1);
    closePosition(user, index2, address(aaveV3Connector), address(sparkConnector), position2);
  }

  function _getOpenConnectorDatas(DataTypes.Position memory position) internal view override returns (bytes[] memory) {
    bytes[] memory datas = new bytes[](3);
    datas[0] = _getDepositCallData(position.collateralAsset, position.collateralAmount);
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
    datas[2] = _getWithdrawCallData(position.collateralAsset, position.collateralAmount);
    return datas;
  }

  function _getDepositCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.deposit.selector, token, amount);
  }

  function _getBorrowCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.borrow.selector, token, amount, RATE_TYPE);
  }

  function _getPaybackCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.payback.selector, token, amount, RATE_TYPE);
  }

  function _getWithdrawCallData(address token, uint256 amount) internal view returns (bytes memory) {
    return abi.encodeWithSelector(sparkConnector.withdraw.selector, token, amount);
  }
}

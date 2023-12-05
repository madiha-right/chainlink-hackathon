// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { DataTypes } from "contracts/lib/DataTypes.sol";
import { PercentageMath } from "contracts/lib/PercentageMath.sol";

import { IRouter } from "contracts/interfaces/IRouter.sol";
import { IConnector } from "contracts/interfaces/IConnector.sol";

import { DeployCoreContracts } from "../../utils/deployer/core.sol";

contract UniversalPosition is DeployCoreContracts {
  using SafeERC20 for IERC20;

  function openPosition(
    address user,
    address debtAsset,
    address collateralAsset,
    uint256 borrowAmount,
    uint256 collateralAmount,
    address delegationConnector,
    address lendingConnector
  ) public returns (DataTypes.Position memory, uint256) {
    (, uint64 destChainSelector,) = getCcipInfo();
    address ccip = addressesProvider.getCcip();

    DataTypes.Position memory position = DataTypes.Position(
      user,
      debtAsset,
      collateralAsset,
      borrowAmount,
      collateralAmount,
      IConnector(delegationConnector).NAME(),
      destChainSelector,
      ccip
    );

    vm.startPrank(position.account);
    deal(position.debtAsset, address(this), 10000); // add padding to avoid rounding errors on repay
    deal(position.collateralAsset, position.account, position.collateralAmount * 2);
    IERC20(position.collateralAsset).forceApprove(address(router), position.collateralAmount * 2);
    vm.stopPrank();

    deal(position.collateralAsset, address(this), position.collateralAmount * 2);
    IERC20(position.collateralAsset).forceApprove(address(router), position.collateralAmount * 2);
    router.delegate(position.collateralAsset, position.collateralAmount * 2);

    bytes memory data = _getOpenPositionCallData(delegationConnector, lendingConnector, position);

    vm.prank(position.account);
    router.openPosition(position, data);

    uint256 index = router.positionsIndex(position.account);

    return (position, index);
  }

  function closePosition(
    address user,
    uint256 indexPosition,
    address delegationConnector,
    address lendingConnector,
    DataTypes.Position memory position
  ) public {
    bytes32 key = router.getKey(position.account, indexPosition);
    bytes memory data = _getClosePositionCallData(key, delegationConnector, lendingConnector, position);

    vm.prank(user);
    router.closePosition(key, data);
  }

  function _getOpenPositionCallData(
    address delegationConnector,
    address lendingConnector,
    DataTypes.Position memory position
  ) internal view returns (bytes memory) {
    string[] memory targetNames = _getOpenConnectorNames(delegationConnector, lendingConnector);
    bytes[] memory datas = _getOpenConnectorDatas(position);

    return abi.encode(targetNames, datas);
  }

  function _getClosePositionCallData(
    bytes32 key,
    address delegationConnector,
    address lendingConnector,
    DataTypes.Position memory position
  ) internal view returns (bytes memory) {
    string[] memory targetNames = _getCloseConnectorNames(delegationConnector, lendingConnector);
    bytes[] memory datas = _getCloseConnectorDatas(position, key);

    return abi.encode(targetNames, datas);
  }

  function _getOpenConnectorNames(address delegationConnector, address lendingConnector)
    internal
    view
    returns (string[] memory names)
  {
    names = new string[](3);
    names[0] = IConnector(delegationConnector).NAME();
    names[1] = IConnector(lendingConnector).NAME();
    names[2] = IConnector(lendingConnector).NAME();
  }

  function _getCloseConnectorNames(address delegationConnector, address lendingConnector)
    internal
    view
    returns (string[] memory names)
  {
    names = new string[](3);
    names[0] = IConnector(lendingConnector).NAME();
    names[1] = IConnector(lendingConnector).NAME();
    names[2] = IConnector(delegationConnector).NAME();
  }

  function _getOpenConnectorDatas(DataTypes.Position memory position) internal view virtual returns (bytes[] memory) { }

  function _getCloseConnectorDatas(DataTypes.Position memory position, bytes32 positionKey)
    internal
    view
    virtual
    returns (bytes[] memory)
  { }

  function _getPositionKey(address user) internal view returns (bytes32 key) {
    uint256 index = router.positionsIndex(user);
    key = router.getKey(user, index + 1);
  }
}

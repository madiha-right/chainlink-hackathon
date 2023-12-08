// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { console } from "forge-std/Console.sol";
import { Script } from "forge-std/Script.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { DataTypes } from "contracts/lib/DataTypes.sol";
import { PercentageMath } from "contracts/lib/PercentageMath.sol";

import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
import { IRouter } from "contracts/interfaces/IRouter.sol";
import { IConnector } from "contracts/interfaces/IConnector.sol";

import { Constants } from "./Constants.sol";
import { Tokens } from "utils/Tokens.sol";

contract UniversalPosition is Constants, Tokens, Script {
  using SafeERC20 for IERC20;

  enum PositionType {
    OPEN,
    CLOSE
  }

  function openPosition(DataTypes.Position memory position, address delegationConnector, address lendingConnector)
    public
    returns (DataTypes.Position memory, uint256)
  {
    address router = ADDRESSES_PROVIDER.getRouter();

    IERC20(position.collateralAsset).forceApprove(address(router), position.collateralAmount);
    // IRouter(router).delegate(position.collateralAsset, position.collateralAmount * 2);

    bytes memory data = _getOpenPositionCallData(delegationConnector, lendingConnector, position);

    IRouter(router).openPosition(position, data);

    uint256 index = IRouter(router).positionsIndex(position.account);

    return (position, index);
  }

  function closePosition(address user, uint256 indexPosition, address delegationConnector, address lendingConnector)
    public
  {
    address router = ADDRESSES_PROVIDER.getRouter();
    bytes32 key = IRouter(router).getKey(user, indexPosition);
    (
      address account,
      address debtAsset,
      address collateralAsset,
      uint256 borrowAmount,
      uint256 collateralAmount,
      string memory delegationTargetName,
      uint64 destinationChainSelector,
      address destinationReceiver
    ) = IRouter(router).positions(key);

    bytes memory data = _getClosePositionCallData(
      key,
      delegationConnector,
      lendingConnector,
      IRouter(router).getOrCreateAccount(account),
      DataTypes.Position(
        account,
        debtAsset,
        collateralAsset,
        borrowAmount,
        collateralAmount,
        delegationTargetName,
        destinationChainSelector,
        destinationReceiver
      )
    );

    IRouter(router).closePosition(key, data);
  }

  function _getOpenPositionCallData(
    address delegationConnector,
    address lendingConnector,
    DataTypes.Position memory position
  ) internal view returns (bytes memory) {
    string[] memory targetNames = _getConnectorNames(delegationConnector, lendingConnector);
    bytes[] memory datas = _getOpenConnectorDatas(position);

    return abi.encode(targetNames, datas);
  }

  function _getClosePositionCallData(
    bytes32 key,
    address delegationConnector,
    address lendingConnector,
    address user,
    DataTypes.Position memory position
  ) internal view returns (bytes memory) {
    string[] memory targetNames = _getConnectorNames(delegationConnector, lendingConnector);
    bytes[] memory datas = _getCloseConnectorDatas(position, key, user);
    bytes memory params = abi.encode(
      position.account, position.collateralAsset, position.collateralAmount, position.borrowAmount, PositionType.CLOSE
    );

    return abi.encode(targetNames, datas, params);
  }

  function _getConnectorNames(address delegationConnector, address lendingConnector)
    internal
    view
    returns (string[] memory names)
  {
    names = new string[](3);
    names[0] = IConnector(delegationConnector).NAME();
    names[1] = IConnector(lendingConnector).NAME();
    names[2] = IConnector(lendingConnector).NAME();
  }

  function _getOpenConnectorDatas(DataTypes.Position memory position) internal pure virtual returns (bytes[] memory) { }

  function _getCloseConnectorDatas(DataTypes.Position memory position, bytes32 positionKey, address user)
    internal
    view
    virtual
    returns (bytes[] memory)
  { }

  function _getPositionKey(address user) internal view returns (bytes32 key) {
    address router = ADDRESSES_PROVIDER.getRouter();
    uint256 index = IRouter(router).positionsIndex(user);
    key = IRouter(router).getKey(user, index + 1);
  }
}

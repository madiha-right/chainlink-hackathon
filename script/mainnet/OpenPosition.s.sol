// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.20;

// import { Script } from "forge-std/Script.sol";
// import { console } from "forge-std/Console.sol";

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import { IAddressesProvider } from "contracts/interfaces/IAddressesProvider.sol";
// import { DataTypes } from "contracts/lib/DataTypes.sol";

// import { Tokens } from "utils/Tokens.sol";

// contract OpenPosition is Tokens, Script {
//   IAddressesProvider constant ADDRESSES_PROVIDER = IAddressesProvider(0x0782bb971E6F251FadD04d7a6a03fd870C694047);
// 	address constant SDAI_CONNECTOR =

//   function run() public {
//     uint256 pk = vm.envUint("PRIVATE_KEY");
//     // address account = vm.addr(pk);
//     vm.startBroadcast(pk);

//     _openPositionAaveV3();

//     vm.stopBroadcast();
//   }

//   function _openPositionAaveV3() private {
//     address connectors = ADDRESSES_PROVIDER.getConnectors();
// 		IConnectors(connectors).connector

//     (DataTypes.Position memory position, uint256 index) = _openPosition(
//       msg.sender,
//       getToken("weth"),
//       getToken("dai"),
//       0.1 ether,
//       1000 ether,
//       address(sDAIConnector),
//       address(aaveV3Connector)
//     );
//   }

//   function _openPosition(
//     address user,
//     address debtAsset,
//     address collateralAsset,
//     uint256 borrowAmount,
//     uint256 collateralAmount,
//     address delegationConnector,
//     address lendingConnector
//   ) private returns (DataTypes.Position memory, uint256) {
//     (, uint64 destChainSelector,) = getCcipInfo();
//     address ccip = ADDRESSES_PROVIDER.getCcip();

//     DataTypes.Position memory position = DataTypes.Position(
//       user,
//       debtAsset,
//       collateralAsset,
//       borrowAmount,
//       collateralAmount,
//       IConnector(delegationConnector).NAME(),
//       destChainSelector,
//       ccip
//     );

//     vm.startPrank(position.account);
//     deal(position.debtAsset, address(this), 10000); // add padding to avoid rounding errors on repay
//     deal(position.collateralAsset, position.account, position.collateralAmount * 2);
//     IERC20(position.collateralAsset).forceApprove(address(router), position.collateralAmount * 2);
//     vm.stopPrank();

//     deal(position.collateralAsset, address(this), position.collateralAmount * 2);
//     IERC20(position.collateralAsset).forceApprove(address(router), position.collateralAmount * 2);
//     router.delegate(position.collateralAsset, position.collateralAmount * 2);

//     bytes memory data = _getOpenPositionCallData(delegationConnector, lendingConnector, position);

//     vm.prank(position.account);
//     router.openPosition(position, data);

//     uint256 index = router.positionsIndex(position.account);

//     return (position, index);
//   }
// }

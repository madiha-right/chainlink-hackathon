// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Errors library
 * @author zRex
 * @notice Defines the error messages emitted by the different contracts of the zRex protocol
 */
library Errors {
  error CallerNotAccountOwner(); // The caller of the function is not a account owner
  error CallerNotReceiver(); // The caller of the function is not a account contract
  error CallerNotPositionOwner(); // The caller of the function is not a position owner
  error InvalidAddressProvider(); // The address of the pool addresses provider is invalid
  error ChargeFeeNotCompleted(); // Failed to charge the protocol fee
  error AccountDoesNotExist(); // The sender does not have an account
  error InvalidChargeAmount(); // Invalid amount to charge fee
  error InvalidAmountAction(); // Invalid amount to deposit or withdraw
  error InsufficientBalance(); // Insufficient balance to perform the operation

  error NotConnector(); // There is no connector with this name
  error InvalidConnectorAddress(); // The address of the connector is invalid
  error InvalidConnectorsLength(); // The length of the connector array and their names are different
  error ConnectorAlreadyExist(); // A connector with this name already exists
  error ConnectorDoesNotExist(); // A connector with this name does not exist
  error InvalidDelegateTargetName(); // The name of the delegate target does not match

  error NotVault(); // There is no vault with this name
  error InvalidVaultAddress(); // The address of the vault is invalid
  error InvalidVaultsLength(); // The length of the vault array and their names are different
  error VaultAlreadyExist(); // A vault with this name already exists
  error VaultDoesNotExist(); // A vault with this name does not exist
  error VaultAssetDoesNotMatch(); // A underlying asset address of vault does not match with the given asset address

  error CallerNotConfigurator(); // The caller of the function is not a configurator
  error InvalidFeeAmount(); // The fee amount is invalid
  error InvalidImplementationAddress(); // The address of the implementation is invalid
  error ACLAdminCannotBeZero(); // 'ACL admin cannot be set to the zero address'
  error CallerNotRouterAdmin(); // 'The caller of the function is not a router admin'
  error CallerNotEmergencyAdmin(); // 'The caller of the function is not an emergency admin'
  error CallerNotConnectorAdmin(); // 'The caller of the function is not an connector admin'
  error CallerNotVaultAdmin(); // 'The caller of the function is not an vault admin'
  error AddressIsZero(); // Address should be not zero address
  error CallerNotRouter(); // The caller of the function is not a router contract
  error ExecuteOperationFailed(); // The call to the open/close callback function failed
}

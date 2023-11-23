// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IACLManager {
  function setRoleAdmin(bytes32 _role, bytes32 _adminRole) external;

  function addConnectorAdmin(address _admin) external;

  function removeConnectorAdmin(address _admin) external;

  function addVaultAdmin(address _admin) external;

  function removeVaultAdmin(address _admin) external;

  function addRouterAdmin(address _admin) external;

  function removeRouterAdmin(address _admin) external;

  function isConnectorAdmin(address _admin) external view returns (bool);

  function isVaultAdmin(address _admin) external view returns (bool);

  function isRouterAdmin(address _admin) external view returns (bool);
}

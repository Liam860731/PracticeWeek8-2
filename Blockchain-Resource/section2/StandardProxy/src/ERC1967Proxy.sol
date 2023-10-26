// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Slots } from "./utils/Slots.sol";
import { Proxy } from "./utils/Proxy.sol";

contract ERC1967Proxy is Slots, Proxy {
  address public adminOwner;
  bytes32 constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);
  bytes32 constant ADMIN_SLOT = bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1);

  constructor(address _impl, bytes memory _data) {
    // TODO:
    adminOwner = msg.sender;
    // 1. set the implementation address at bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    // 2. set admin owner address at bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    // 3. if data exist, then initialize proxy with _data
    _setSlotToAddress(IMPLEMENTATION_SLOT, _impl);
    _setSlotToAddress(ADMIN_SLOT, msg.sender);

    if (_data.length > 0) {
      (bool success, ) = _impl.delegatecall(_data);
      require(success, "init failed");
    }
  }

  function implementation() public view returns (address impl) {
    // TODO: return the implementation address
    return _getSlotToAddress(IMPLEMENTATION_SLOT);
  }

  modifier onlyAdmin {
    // TODO: check if msg.sender is equal to admin owner address
    require(msg.sender == _getSlotToAddress(ADMIN_SLOT), "You are not admin.");
    _;
  }

  function upgradeToAndCall(address newImplementation, bytes memory _data) external onlyAdmin {
    // TODO:
    // 1. upgrade the implementation address
    // 2. initialize proxy, if data exist, then initialize proxy with _data
    _setSlotToAddress(IMPLEMENTATION_SLOT, newImplementation);
    if(_data.length > 0){
      (bool success, ) = newImplementation.delegatecall(_data);
    require(success, "init failed");
    }
  }

  fallback() external payable virtual {
    _delegate(implementation());
  }

  receive() external payable {
    _delegate(implementation());
  }
}
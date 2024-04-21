// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Proxy {
    address public admin;
    address public implementation;

    constructor() {
        admin = msg.sender;
    }

    function update(address _implementation) external {
        require(msg.sender == admin, "Only admin can update implementation");
        implementation = _implementation;
    }

    fallback() payable external {
        require(implementation != address(0), "Implementation address not set");
        
        address impl = implementation;
        assembly {
            // Copy incoming call data
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // Delegatecall to the implementation contract
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            // Copy the returned data
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            // Check the result of the delegatecall
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
    receive() payable external {}
}

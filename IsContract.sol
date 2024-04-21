// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract IsContract {
  function isContract(address addr) view external returns(bool) {
    uint256 codeLength;
    
    assembly {codeLength := extcodesize(addr)}
    return codeLength == 0 ? false : true;
  }
}

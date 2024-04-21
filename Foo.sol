// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25;

contract Foo {
    function id(string calldata name, uint age) external pure returns (string calldata, uint) {
        return (name, age);
    }
}
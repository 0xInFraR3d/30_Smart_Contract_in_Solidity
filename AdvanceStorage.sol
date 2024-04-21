// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract AdvanceStorage{
    uint256[] public ids;

    function add(uint256 id) public {
        ids.push(id);
    }
    function get(uint256 position) view public  returns (uint256) {
        return ids[position];
    }
 
    function getAll() view public returns (uint256[] memory) {
        return ids;
    }

    function length() view public returns(uint256) {
        return ids.length;
    }

}
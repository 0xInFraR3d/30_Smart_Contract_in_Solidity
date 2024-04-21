// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EtherWallet {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
    function deposit() payable public {

    }
    function send(address payable to, uint amount) public {
        if(msg.sender == owner) {
            to.transfer(amount);
            return;
        }
        revert("Sender is not the owner! ");
    }

    function balanceOf() view public returns(uint) {
        return address(this).balance;

    }
}
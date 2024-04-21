// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Escrow{
    address public payer;
    address payable public payee;
    address public lawyer;
    uint public amount;

    constructor(address _payer, address payable _payee, uint _amount) {
        payer = _payer;
        payee = _payee;
        lawyer = msg.sender;
        amount = _amount;
        }
    function deposit() payable public{
        require(msg.sender == payer, 'Sender must be the payer');
        require(address(this).balance <= amount);
        }
    function release() view public {
        require(address(this).balance == amount, 'pahle pura paisa bhej fir fund release karunga');
        require(msg.sender == lawyer, 'mai nahi hu bhai lawyer tu apna dekh le');
    }
    function balanceOf() view public returns(uint) {
        return address(this).balance;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery{
    enum State{
        IDLE,
        BETTING
    }
    State public currentState = State.IDLE;
    address payable [] public players;
    uint public betCount;
    uint public betSize;
    uint public houseFee;
    address public admin;

    constructor(uint fee) {
        require(fee>1 && fee < 99, 'fee should be between 1 and 99');
        houseFee = fee;
        admin = msg.sender;
    }

    function createBet(uint count, uint size) external payable inState(State.IDLE) onlyAdmin() {
        betCount = count;
        betSize = size;
        currentState = State.BETTING;
    }
    function bet() external payable inState(State.BETTING) {
        require(msg.value == betSize, 'can only bet exactly the bet size');
        players.push(payable(msg.sender));
        if(players.length == betCount) {
            uint winner = _randomModulo(betCount); //1. pick a winner
            players[winner].transfer((betSize*betCount)*(100-houseFee)/100); //2. send money to the winner
            currentState = State.IDLE; //3. state => IDLE
            delete players; //4. data cleanup
        }
    }
    function cancel() external inState(State.BETTING) onlyAdmin() {
        for (uint i = 0; i < players.length; i++){
            players[i].transfer(betSize);
        }
        delete players;
        currentState = State.IDLE;    
    }
    function _randomModulo(uint modulo) view internal returns(uint) {
       return uint(keccak256(abi.encode(block.timestamp, block.difficulty))) % modulo; 
    }
    modifier inState(State state) {
        require(currentState == state, 'currectState does not allow this');
        _;
    }
    modifier onlyAdmin(){
        require(msg.sender == admin, 'only admin is allowed');
        _;
    }
}
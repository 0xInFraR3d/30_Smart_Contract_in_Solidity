// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Multisig{
    address[] public approvers;
    uint public quorum;
    struct Transfer{
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }

    mapping (uint => Transfer) transfers;
    uint nextID;
    mapping (address => mapping (uint => bool)) approvals;



    constructor (address[] memory _approvers, uint _quorum) payable {
        approvers = _approvers;
        quorum = _quorum;
    }

    function createTransfer(uint amount, address payable to) external onlyApprover() {
        transfers[nextID] = Transfer(nextID, amount, to, 0, false);
        nextID++;
    }
    function sendTransfer(uint id) external onlyApprover() {
        require(transfers[id].sent != false, 'Transfer has already been sent');
        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount);
            return;
        }

        if(approvals[msg.sender][id] == false) {
            approvals[msg.sender][id] = true;
            transfers[id].approvals++;
        }
    }
    modifier onlyApprover(){
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
            require(allowed == true, 'only approvers allowed');
            _;
        }
    }
}
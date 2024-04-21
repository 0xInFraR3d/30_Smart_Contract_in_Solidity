// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DAO {

    struct Proposal{
        uint id;
        string name;
        uint amount;
        address payable recipient;
        uint votes;
        uint end;
        bool executes;
    }
    mapping (address => bool) public investors;
    mapping (address => uint) public shares;
    mapping (uint => Proposal) public proposals;
    mapping (address => mapping (uint=>bool)) public votes;
    uint public totalShares;
    uint public availableFunds;
    uint public contributionEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public admin;

    constructor(uint contributoinTime) {
        contributionEnd = block.timestamp + contributoinTime;
    }

    function contribute() payable external {
        require(block.timestamp < contributionEnd, 'cannot contribute after contributionEnd');
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }

    function redeemShare(uint amount) external  {
        require(shares[msg.sender] >= amount, 'not enough shares to redeem');
        require(availableFunds >= amount, 'not enough available funds');
        shares[msg.sender] -= amount;
        availableFunds -= amount;
        payable(msg.sender).transfer(amount);

    }

    function transferShare(uint amount, address to) external {
        require(shares[msg.sender] >= amount, 'not enough shares');
        shares[msg.sender] -= amount;
        shares[to] += amount;
        investors[to] = true;
    }
    function createProposal(string memory name, uint amount, address payable recipient) external onlyInvestor() {
        require(availableFunds >= amount, 'amount too big');
        proposals[nextProposalId] = Proposal(nextProposalId, name, amount, recipient, 0, block.timestamp + voteTime, false);
        availableFunds -= amount; 
        nextProposalId++;
    }
    function vote(uint proposalID) external onlyInvestor() {
        Proposal storage proposal = proposals[proposalID];
        require(votes[msg.sender][proposalID] == false,'investor can only vote once');
        require(block.timestamp < proposal.end,'can vote until proposal end');
        votes[msg.sender][proposalID] = true;
        proposal.votes += shares[msg.sender];
    }
    function executeProposal(uint proposalID) external onlyAdmin() {
        Proposal storage proposal = proposals[proposalID];
        require(block.timestamp >= proposal.end, 'can not execute before end date');
        require(proposal.executes == false, 'can not execute a proposla already executed');
        require((proposal.votes/totalShares) * 100 >= quorum,'can not execute a proposal with votes below quorum');
        _transferEther(proposal.amount, proposal.recipient);
    }

    function withdrawEther(uint amount, address payable to) external onlyAdmin() {
        _transferEther(amount, to);
    }
    receive() external payable {
        availableFunds += msg.value;
    }

    // Fallback function - not recommended for receiving Ether
    fallback() external payable {
        revert("Fallback function is not allowed");
    }

    function _transferEther(uint amount, address payable to) internal {
        require(amount <= availableFunds, 'not enought availableFunds');
        availableFunds -= amount;
        to.transfer(amount);
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }
    modifier onlyInvestor() {
        require(investors[msg.sender] == true, 'only investors');
        _;
    }
}
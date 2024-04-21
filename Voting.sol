// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting{
    mapping(address => bool) public voters;
    struct Choice{
        uint id;
        string name;
        uint votes;
    }
    struct Ballot{
        uint id;
        string name;
        Choice[] choices;
        uint end;
    }
    mapping (uint => Ballot) ballots;
    uint nextBallotID;
    address public admin;
    mapping(address=>mapping(uint => bool)) votes;
    constructor() {
        admin = msg.sender;
    }

    function addVoters(address[] calldata _voters) external {
        for(uint i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }

    function createBallot(string memory name, string[] memory choices, uint offset) public onlyAdmin() {
        ballots[nextBallotID].id = nextBallotID;
        ballots[nextBallotID].name = name;
        ballots[nextBallotID].end = block.timestamp + offset;
        for(uint i = 0; i < choices.length; i++){
            ballots[nextBallotID].choices.push(Choice(i,choices[i], i));
        }
    }

    function vote(uint ballotId, uint choiceId) external {
        require(voters[msg.sender]==true, ' only voters can vote.');
        require(votes[msg.sender][ballotId] == false, 'voters can only vote once for a ballot');
        require(block.timestamp < ballots[ballotId].end, 'can only vote untill ballot vote date');
        votes[msg.sender][ballotId] = true;
        ballots[ballotId].choices[choiceId].votes++;
    }

    function results(uint ballotId) view external returns(Choice[] memory) {
        require(block.timestamp >= ballots[ballotId].end, 'can not see the ballot reason');
        return ballots[ballotId].choices;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin, 'only admin');
        _;
    }
}
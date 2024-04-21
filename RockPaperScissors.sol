// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract RockPaperScissors {
    enum State {
        CREATE,
        JOINED,
        COMMITED,
        REVEALED
    }

    struct Game{
        uint id;
        uint bet;
        address payable [2] players;
        State state;
    }

    struct Move {
        bytes32 hash;
        uint value;
    }

    mapping (uint => Game) public games;
    mapping (uint => mapping (address => Move)) public moves;
    mapping(uint => uint) public winningMoves;

    uint public gameId;

    constructor() {
        winningMoves[1] = 3;
        winningMoves[2] = 1;
        winningMoves[3] = 2;
    }

    function createGame(address payable participant) external payable {
        require(msg.value > 0, 'need to send some ether');
        address payable[2] memory players;
        players[0] = payable(msg.sender);
        players[1] = participant;

        games[gameId] = Game(gameId,msg.value,players,State.CREATE);
        gameId++;
    }

    function joinGame(uint _gameId) external payable {
        Game storage game = games[_gameId];
        require(game.players[1] == msg.sender, 'sender must be second player');
        require(game.state == State.JOINED, 'must be in CREATED state');
        require(game.bet <= msg.value, 'not enough ether sent');
        if(msg.value > game.bet) {
            payable(msg.sender).transfer(msg.value - game.bet);
        }
        game.state = State.JOINED;
    }

    function commitMove(uint _gameId, uint moveId, uint salt) external {
        Game storage game = games[_gameId];
        require(game.state == State.JOINED, 'Game must be in JOINED state');
        require(game.players[0] == msg.sender || game.players[1] == msg.sender, 'can only be called by one of the player');
        require(moves[_gameId][msg.sender].hash != 0, 'move already made');
        require(moveId == 1 || moveId == 2 || moveId == 3, 'move must be either 1, 2 or 3');
        moves[_gameId][msg.sender] = Move(keccak256(abi.encodePacked(moveId, salt)), 0);
        if(moves[_gameId][game.players[0]].hash != 0 && moves[_gameId][game.players[1]].hash != 0) {
            game.state = State.COMMITED;
        }
    }
    function revealMove(uint _gameId, uint moveId, uint salt) external {
        Game storage game = games[_gameId];
        Move storage move1 = moves[_gameId][game.players[0]];
        Move storage move2 = moves[_gameId][game.players[1]];
        Move storage moveSender = moves[_gameId][msg.sender];
        require(game.state == State.COMMITED, 'game must be in COMMITED state');
        require(game.players[0] == msg.sender || game.players[1] == msg.sender, 'can only be called by one of the player');
        require(moveSender.hash == keccak256(abi.encodePacked(moveId, salt)), 'moveId does not match commitment');
        moveSender.value == moveId;
        if(move1.value != 0 && move2.value != 0) {
            if(move1.value == move2.value) {
                game.players[0].transfer(game.bet);
                game.players[1].transfer(game.bet);
                game.state = State.REVEALED;
                return;
            }
            address payable winner;
            winner = winningMoves[move1.value] == move2.value ? game.players[0] : game.players[1];
            winner.transfer(2*game.bet);
            game.state = State.REVEALED;
        }
    }
}
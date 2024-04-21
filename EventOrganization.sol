// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EventContract {
    struct Event {
        address admin;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemaining;
    }
    mapping (uint => Event) public events;
    mapping (address => mapping(uint => uint)) public tickets;
    uint public nextID;

    function createEvent(string calldata name, uint date, uint price, uint ticketCount) external {
        require(date>block.timestamp, 'event can only be organized in the future');
        require(ticketCount > 0, 'can only create event with at least 1 ticket available');
        events[nextID] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextID++;
    }

    function buyTicket(uint id, uint quantity) payable external eventExist(id) eventActive(id) {
        Event storage _event = events[id];
        require(msg.value == (_event.price*quantity), 'not enough ether sent');
        require(_event.ticketRemaining >= quantity, 'not enough ticket left');
        _event.ticketRemaining -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint eventId, uint quantity, uint amount, address to) external eventExist(eventId) eventActive(eventId) {
        require(tickets[msg.sender][eventId] >= quantity, 'not enough tickes');
        tickets[msg.sender][eventId] -= quantity;
        tickets[to][eventId] += quantity;
    }

    modifier eventExist(uint id) {
        require(events[id].date != 0,'this event does not exist');
        _;
    }
    modifier eventActive(uint id) {
        require(events[id].date > block.timestamp, 'this event is not active anymore');
        _;
    }
}
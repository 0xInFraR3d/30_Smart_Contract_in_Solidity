// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dex {
    mapping(string => uint) private prices;
    function getPrice(string calldata _sticker) external view returns(uint) {
        return prices[_sticker];
    }
    
    function buy(string calldata _sticker, uint _amount, uint _price) external {
        //Buy ERC20 token
    }
    
    function sell(string calldata _sticker, uint _amount, uint _price) external {
        //Sell ERC20 token
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

//452413  gas spent on deploying the contract

error NotOwner();

contract FundMeLib {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 0; // 10 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmount;
    address immutable public i_owner;

    constructor() {
        i_owner = msg.sender;
    }
    
    function fund() public payable{
        // 1. To be able send funds to the contract
        // 2. To set a minimum sending value as 1 ETH in USD eq.
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didnt send amount");
        funders.push(msg.sender);
        addressToAmount[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmount[funder] = 0;
        }
        funders = new address[](0);

        // actually withdraw the funds
        // there are three ways to send funds from one contract to another:
        // 1. transfer()
        // payable(msg.sender).transfer(address(this).balance);
        // 2. send()
        // payable(msg.sender).send(address(this).balance);
        // 3. call()
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call filed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) {revert NotOwner();}
        _;
    }
}
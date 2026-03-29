// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts@1.5.0/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {console} from "forge-std/Script.sol";

//452413  gas spent on deploying the contract

error FundMe__NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // 10 * 1e18;
    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmount;
    address immutable private i_owner;
    AggregatorV3Interface public s_feedAddress;

    constructor(address feed) {
        i_owner = msg.sender;
        s_feedAddress = AggregatorV3Interface(feed);
        console.log("initial Balance is ", address(this).balance);
        console.log(address(this));
    }
    
    function fund() public payable{
        // 1. To be able send funds to the contract
        // 2. To set a minimum sending value as 1 ETH in USD eq.
        require(msg.value.getConversionRate(s_feedAddress) >= MINIMUM_USD, "Didn't send amount");
        s_funders.push(msg.sender);
        s_addressToAmount[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmount[funder] = 0;
        }
        s_funders = new address[](0);

        // actually withdraw the funds
        // there are three ways to send funds from one contract to another:
        // 1. transfer()
        // payable(msg.sender).transfer(address(this).balance);
        // 2. send()
        // payable(msg.sender).send(address(this).balance);
        // 3. call()
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns(uint256) {
        // get current version of the contract of the aggregator
        uint256 version = s_feedAddress.version();
        return version;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) {revert FundMe__NotOwner();}
        _;
    }

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmount[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    receive() external payable {
        fund();
     }

    fallback() external payable { 
        fund();
     }
}
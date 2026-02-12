// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {AggregatorV3Interface} from "@chainlink/contracts@1.5.0/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    uint256 public minimumUsd = 10 * 1e18;
    
    function fund() public payable{
        // 1. To be able send funds to the contract
        // 2. To set a minimum sending value as 1 ETH in USD eq.
        require(getConversionRate(msg.value) >= minimumUsd, "Didnt send amount");
    }

    function getVersion() public view returns(uint256) {
        uint256 version = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
        return version;
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer, , ,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)  / 1e18;
        return ethAmountInUsd;
    }

    function getDecimals() public view returns(uint8) {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    uint8 answer = priceFeed.decimals();
    return answer;
    }
}
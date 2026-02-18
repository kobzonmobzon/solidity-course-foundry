// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// импортируем интерфейс для дадафида
import {AggregatorV3Interface} from "@chainlink/contracts@1.5.0/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    
    function getVersion() internal view returns(uint256) {
        // get current version of the contract of the aggregator
        uint256 version = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
        return version;
    }

    function getPrice() internal view returns(uint256) {
        // get price from agregator. all addresses are here https://docs.chain.link/data-feeds/price-feeds/addresses?networkType=testnet&testnetPage=2
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer, , ,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint ethAmount) internal view returns(uint256) {
        // converting amount in ETH to the amount in USD
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)  / 1e18;
        return ethAmountInUsd;
    }

    function getDecimals() internal view returns(uint8) {
        // as interfaces could return different decimals for uint, we should check what is the actual decimal to operate correct numbers
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    uint8 answer = priceFeed.decimals();
    return answer;
    }
}
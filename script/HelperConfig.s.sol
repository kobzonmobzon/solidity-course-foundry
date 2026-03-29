// SPDX-License-Identifier: MIT


// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address accross different chains:
  // Sepolia ETH/USD
  // Mainnet ETH/USD


pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {

  uint8 public constant DECIMALS = 8;
  int public constant INITIAL_PRICE = 2000e8;
  uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
  uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
  address public constant SEPOLIA_PRICE_FEED_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
  address public constant ETH_MAINNET_PRICE_FEED_ADDRESS = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  NetworkConfig public activeNetworkConfig;

  struct NetworkConfig {
    address priceFeed; // ETH/USD feed address 
  }

  constructor() {
    /*
    if(block.chainid == SEPOLIA_CHAIN_ID) {
      activeNetworkConfig = getSepoliaEthConfig();
    } else if(block.chainid == ETH_MAINNET_CHAIN_ID) {
      activeNetworkConfig = getMainnetEthConfig();
    } else {
      activeNetworkConfig = getAnvilEthConfig();
    }
    */

    if(block.chainid == SEPOLIA_CHAIN_ID) {
      activeNetworkConfig = getActiveEthConfig(SEPOLIA_PRICE_FEED_ADDRESS);
    } else if(block.chainid == ETH_MAINNET_CHAIN_ID) {
      activeNetworkConfig = getActiveEthConfig(ETH_MAINNET_PRICE_FEED_ADDRESS);
    } else {
      activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
  }

  function getActiveEthConfig(address priceFeedAddress) public pure returns(NetworkConfig memory) {
      NetworkConfig memory networkConfig = NetworkConfig({priceFeed: priceFeedAddress});
      return networkConfig;
  }

/*
  function getSepoliaEthConfig() public returns (NetworkConfig memory) {

    NetworkConfig memory sepoliaConfig = NetworkConfig(
      {priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    return sepoliaConfig;
  }

  function getMainnetEthConfig() public returns (NetworkConfig memory) {

    NetworkConfig memory ethConfig = NetworkConfig(
      {priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    return ethConfig;
  }
*/
  
  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {

    if(activeNetworkConfig.priceFeed != address(0)) {
      return activeNetworkConfig;
    }

    vm.startBroadcast();
    MockV3Aggregator mockPricefeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPricefeed)
    });

    return anvilConfig;
  }

}
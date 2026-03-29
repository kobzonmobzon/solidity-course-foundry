// SPDX-License-Identifier: MIT

// This script is for fund and withdraw from FundMe.sol contract

pragma solidity ^0.8.33;


import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{
  uint256 constant SEND_VALUE = 0.01 ether;

  function fundFundMe(address mostRecentDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
    vm.stopBroadcast();
    console.log("Funded FundMe contract with %s", SEND_VALUE);
    console.log("current Balance is ", mostRecentDeployed.balance);
  }

  function run() external {
    address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
      "FundMe", block.chainid
    );
    fundFundMe(mostRecentDeployed);
  }
}

contract WithdrawFundMe is Script{

  function withdrawFundMe(address mostRecentDeployed) public {

    vm.startBroadcast();
    FundMe(payable(mostRecentDeployed)).withdraw();
    vm.stopBroadcast();
    console.log("Withdrawed FundMe contract");
  }

  function run() external {
    address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
      "FundMe", block.chainid
    );
    withdrawFundMe(mostRecentDeployed);
  }
}

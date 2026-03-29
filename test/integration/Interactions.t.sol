// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {

  uint256 constant SEND_VALUE = 0.01 ether;
  
  FundMe fundMe;
  address USER = makeAddr("user");
  uint256 constant STARTING_AMOUNT = 10 ether;

  function setUp() external {
    DeployFundMe deploy = new DeployFundMe();
    fundMe = deploy.run();
    vm.deal(USER, STARTING_AMOUNT);
  }

  function testUserCanFundInteractions() public {
    uint256 initialBalance = address(fundMe).balance;

    FundFundMe fundFundMe = new FundFundMe();
    fundFundMe.fundFundMe(address(fundMe));

    assertEq(SEND_VALUE + initialBalance, address(fundMe).balance);

    WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    withdrawFundMe.withdrawFundMe(address(fundMe));

    assertEq(0, address(fundMe).balance);
  }
}
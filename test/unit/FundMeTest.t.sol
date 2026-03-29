// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("user");
    uint256 constant FUNDED_AMOUNT = 0.1 ether;
    uint256 constant STARTING_AMOUNT = 10 ether;


    function setUp() external {
      //fundMe = new FundMe();
      deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
    }

    function testMinimumUsdIsFive() public view {
      assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public view {
      assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersionIsAccurate() public view {
      uint256 version = fundMe.getVersion();
      if(block.chainid == 11155111) {
        assertEq(version, 4);
      } else if (block.chainid == 1) {
        assertEq(version, 6);
      }
    }

    function testFundFailsWithoutEnoughEth() public {
      vm.expectRevert(); // the next line is expexted to revert
      fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {

      uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
      assertEq(amountFunded, FUNDED_AMOUNT);
    }

    function testAddsFunderToFunderArray() public funded {

      address funder = fundMe.getFunder(0);
      assertEq(USER, funder);
    }

    function testOnlyOwnerCanWithdraw() public funded {

      vm.expectRevert();
      vm.prank(USER);
      fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
      // arrange
      uint256 startingOwnerBalance = fundMe.getOwner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;
      
      // act
      vm.prank(fundMe.getOwner());
      fundMe.withdraw();

      // assert
      uint256 endingOwnerBalance = fundMe.getOwner().balance;
      uint256 endingFundMeBalance = address(fundMe).balance;

      assertEq(endingFundMeBalance, 0);
      assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public {

      // arrange

      uint160 numberOfFunders = 10;
      uint160 startingFunderIndex = 1;

      for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
        // The next line - hoax is equal to prank and deal
        // vm.prank(USER); // The next TX will be sent by USER
        // vm.deal(USER, STARTING_AMOUNT); // give 10 ether to USER
        hoax(address(i), STARTING_AMOUNT);
        fundMe.fund{value: FUNDED_AMOUNT}();
      }

      uint256 startingOwnerBalance = fundMe.getOwner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;
      
      // act
      vm.prank(fundMe.getOwner());
      fundMe.withdraw();

      // Assert
      uint256 endingOwnerBalance = fundMe.getOwner().balance;
      uint256 endingFundMeBalance = address(fundMe).balance;

      assertEq(endingFundMeBalance, 0);
      assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);


    }

    modifier funded() {
      vm.prank(USER); // The next TX will be sent by USER
      vm.deal(USER, STARTING_AMOUNT); // give 10 ether to USER
      fundMe.fund{value: FUNDED_AMOUNT}();
      _;
    }

}
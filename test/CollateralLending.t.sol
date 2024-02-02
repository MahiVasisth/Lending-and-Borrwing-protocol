// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {CollateralLending} from "../src/CollateralLending.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {OurToken} from "../src/OurToken.sol";
contract CollateralLendingTest is StdCheats,Test {
   using SafeERC20 for IERC20;
    CollateralLending public lending;
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    address User = makeAddr("User");
    OurToken public token;
    address bob;
    address alice;

    function setUp() public {
    token = new OurToken(1000e18);
    lending = new CollateralLending(address(token));
    bob = makeAddr("bob");
    alice = makeAddr("alice");
    token.transfer(bob, BOB_STARTING_AMOUNT);

    vm.deal(User,100e18);     
  }

   function testallowance() public { 
       uint256 initialAllowance = 1000;
        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        token.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
        uint256 amount = token.balanceOf(alice);
        uint256 depositamount = amount - 100 ;
        assertEq(token.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
        lending.depositToken(depositamount);
        assertEq(token.balanceOf(alice), 100 );
        
   }
     
   function testlending() public {
   uint256 balanceBefore = address(lending).balance;
   console.log(balanceBefore);
  lending.depositToken(1 ether);
  uint256 balanceAfter = address(lending).balance;
  console.log(balanceAfter);
  assertEq(balanceAfter - balanceBefore, 1 ether, "expect increase of 1 ether");
   }
  
   /*function testdeposit() public {
    vm.startPrank(User);
    // token.approve(address(lending),100e18);
    lending.depositToken(100e18);
    assertEq(token.balanceOf(User) , 0);

    } */ 

 
   
   receive() external payable{}

}
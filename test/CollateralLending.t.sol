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
    uint256 amount = 10;
    uint256 withdraw_amount;
    uint256 public  AMOUNT_COLLATERAL ;
    uint256 public borrowamount ;
    OurToken public token;
    address bob;
    
    function setUp() public {
    token = new OurToken(1000e18);
    lending = new CollateralLending(address(token));
    bob = makeAddr("bob");
    token.mint(address(this), 1000e18);
    token.transfer(address(lending), 1000e18);
  }

    modifier deposit_tokens() {
      vm.startPrank(bob);
     token.mint(address(bob),amount);
     token.approve(address(lending),amount);
     lending.depositToken(amount);
     vm.stopPrank();
        _;
    }

   function testDeposit() public deposit_tokens {
     assertEq(token.balanceOf(address(lending)),amount);
   }
     
   function testwithdraw_reverts_if_withdrawisgreaterthendeposit() public deposit_tokens {
    vm.startPrank(bob);
     withdraw_amount = amount+1; 
     vm.expectRevert();
    lending.withdrawToken(withdraw_amount);
    vm.stopPrank();
   }
 
   function testwithdrawsuccessful() public deposit_tokens {
    vm.startPrank(bob);
    uint256 balance_before = token.balanceOf(address(lending));
    withdraw_amount = 8 ;
    lending.withdrawToken(withdraw_amount);
    
    uint256 balance_after =token.balanceOf(address(lending));
    vm.stopPrank();
    assertEq(balance_before - balance_after, withdraw_amount);
  }

   function testborrowTokenWithCollateralsuccessful() public {
    vm.startPrank(bob);
    borrowamount = 100 ;
    AMOUNT_COLLATERAL = borrowamount * 150 / 100 ; 
    vm.deal(bob,AMOUNT_COLLATERAL );
    lending.borrowTokenWithCollateral{value : AMOUNT_COLLATERAL}(borrowamount);
     assertEq(token.balanceOf(bob) , borrowamount);
     vm.stopPrank();  
  }

  function testrepayTokenWithCollateralsuccessful() public {
    vm.startPrank(bob);
    borrowamount = 100 ;
    AMOUNT_COLLATERAL = borrowamount * 150 / 100 ; 
    vm.deal(bob,AMOUNT_COLLATERAL );
    lending.borrowTokenWithCollateral{value : AMOUNT_COLLATERAL}(borrowamount);
     assertEq(token.balanceOf(bob) , borrowamount);
     token.approve(address(lending),borrowamount);
     lending.repayToken(borrowamount);
     assertEq(token.balanceOf(bob),AMOUNT_COLLATERAL );
     vm.stopPrank();
        
  }
  
   function testliquidatesuccessful() public {
    vm.startPrank(bob);
    borrowamount = 100 ;
    AMOUNT_COLLATERAL = borrowamount * 150 / 100 ; 
    vm.deal(bob,AMOUNT_COLLATERAL+10);
    lending.borrowTokenWithCollateral{value : AMOUNT_COLLATERAL}(borrowamount);
     token.approve(address(lending),borrowamount);
     lending.liquidate{value : AMOUNT_COLLATERAL}(bob , borrowamount );
    //  uint256 balancebefore = token.balanceOf(bob);
     assertEq(AMOUNT_COLLATERAL+ 10 , token.balanceOf(bob));
     vm.stopPrank();
   }
   
    receive() external payable{}

}
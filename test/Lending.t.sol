// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Lending} from "../src/Lending.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {OurToken} from "../src/OurToken.sol";

contract LendingTest is Test {
   using SafeERC20 for IERC20;
    Lending public lending;
    OurToken public token;
    address User = makeAddr("User");
    function setUp() public {
    lending = new Lending(token);
    payable(User).transfer(150 ether);
    // payable(address(lending)).transfer(1500 ether);  
  }
    function testdeposit() public {
      uint256 balanceBefore = address(this).balance;
      lending.deposit(1 ether);
      uint256 balanceAfter = address(this).balance;
    
      assertEq(balanceBefore - balanceAfter, 1 ether, "expect increase of 1 ether");
    }
    function testdeposit_revertwhenamountiszero() public 
    {     
          uint256 amount;
          vm.expectRevert(abi.encodeWithSignature("zero_amount_passed()"));
          lending.deposit(amount);
        }

        function testwithdrawfailedifitsmorethendepositamount() public 
        {     
              uint256 amount = 20 ether;
              uint256 withdraw_amount = 30 ether;
              lending.deposit(amount);
              vm.expectRevert(abi.encodeWithSignature("withdraw_amount_is_greater_then_deposit_amount()"));
              lending.withdraw(withdraw_amount);
        }    
    
    function testwithdrawsuccessful_when_withdrawamountlessthendepositedamount() public 
    {     
      uint256 amount = 20 ether;
      uint256 withdraw_amount = 10 ether;
      lending.deposit(amount);
      uint256 balanceBefore = address(lending).balance;
      lending.withdraw(withdraw_amount);
      uint256 balanceAfter = address(lending).balance;
      assertEq(balanceBefore-balanceAfter,withdraw_amount);
    }
 
    function testborrowfailedifitexceedlendingbalance() public{
      uint256 borrowing_limit = address(lending).balance;
      uint256 amount = borrowing_limit + 1;
      vm.expectRevert(abi.encodeWithSignature("not_enough_balance_in_contract()"));
      lending.borrow(amount);
      }
      function testborrowsuccediftheborrowamoutnotexceedlimit() public{
      uint256 borrowing_limit = address(lending).balance;
      uint256 before_balance = address(this).balance;
      lending.borrow(borrowing_limit);
      uint256 after_balance = address(this).balance;
      assertEq(after_balance-before_balance , borrowing_limit);    
      }
    
      function testrepayfailedifnotenoughamountpayed() public {
        lending.deposit(100 ether);
        uint256 borrowing_limit = address(lending).balance;
        lending.borrow(borrowing_limit);
        vm.expectRevert(abi.encodeWithSignature("repay_amount_notequal_to_borrowed_amount()"));
        lending.repay(2 ether);
      }
      function testrepaysuccessfulifenoughamountpayed() public {
        uint256 borrowing_limit = address(lending).balance;
        uint256 repay_borrow=borrowing_limit;
        uint256 beforebalance = address(this).balance;
        lending.borrow(borrowing_limit);
        lending.repay(repay_borrow);
        uint256 afterbalance = address(this).balance;
        assertEq(beforebalance , afterbalance);     
      }
    receive() external payable{}
   }

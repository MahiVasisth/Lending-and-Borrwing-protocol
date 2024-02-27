// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BasicLending} from "../src/BasicLending.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
contract BasicLendingTest is Test {
    BasicLending public lending;
    address User = makeAddr("User");

    function setUp() public {
    lending = new BasicLending();
    payable(User).transfer(150 ether);
    // payable(address(lending)).transfer(1500 ether);  
  }
    function testdeposit() public {
      uint256 balanceBefore = address(lending).balance;
       console.log(balanceBefore);
      lending.deposit{value: 1 ether}();
      uint256 balanceAfter = address(lending).balance;
      console.log(balanceAfter);
      assertEq(balanceAfter - balanceBefore, 1 ether, "expect increase of 1 ether");
    }
    function testdeposit_revertwhenamountiszero() public 
    {     
          uint256 amount;
          vm.expectRevert("Deposit must be greater than zero");
          lending.deposit{value: amount}();
        }

        function testwithdrawfailedifitsmorethendepositamount() public 
        {     
              uint256 amount = 20 ether;
              uint256 withdraw_amount = 30 ether;
              lending.deposit{value: amount}();
              vm.expectRevert("withdraw amount must be less then or equal to deposited amount");
              lending.withdraw(withdraw_amount);
        }    
    
    function testwithdrawsuccessful_when_withdrawamountlessthendepositedamount() public 
    {     
      uint256 amount = 20 ether;
      uint256 withdraw_amount = 10 ether;
      lending.deposit{value: amount}();
      uint256 balanceBefore = address(lending).balance;
      lending.withdraw(withdraw_amount);
      uint256 balanceAfter = address(lending).balance;
      assertEq(balanceBefore-balanceAfter,withdraw_amount);
    }
 
    function testborrowfailedifitexceedlendingbalance() public{
      uint256 borrowing_limit = address(lending).balance;
      uint256 amount = borrowing_limit + 1;
      vm.expectRevert("Cannot borrow more than available in the pool");
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
        lending.deposit{value:100 ether};
        uint256 borrowing_limit = address(lending).balance;
        uint256 repay_amount ;
        lending.borrow(borrowing_limit);
        vm.expectRevert("Require exact eth amount to repay");
        lending.repayBorrow(2 ether);
      }
      function testrepaysuccessfulifenoughamountpayed() public {
        uint256 borrowing_limit = address(lending).balance;
        uint256 repay_borrow=borrowing_limit;
        uint256 beforebalance = address(this).balance;
        lending.borrow(borrowing_limit);
        lending.repayBorrow(repay_borrow);
        uint256 afterbalance = address(this).balance;
        assertEq(beforebalance , afterbalance);     
      }
// fuzz section

function test_fuzzdeposit(uint256 amount) public {
  uint256 balanceBefore = address(lending).balance;
  lending.deposit{value:amount}();
  uint256 balanceAfter = address(lending).balance;

  assertEq(balanceAfter - balanceBefore, amount, "expect increase of 1 ether");
}

    
function test_fuzzwithdraw(uint256 amount,uint256 withdraw_amount) public 
{     
  // uint256 amount = 20 ether;
  // uint256 withdraw_amount = 10 ether;
  amount = bound (amount,1,1e30);
  withdraw_amount = bound (withdraw_amount,1,1e30);
  lending.deposit{value: amount}();
  uint256 balanceBefore = address(lending).balance;
  lending.withdraw(withdraw_amount);
  uint256 balanceAfter = address(lending).balance;
  assertEq(balanceBefore-balanceAfter,withdraw_amount);
}

  function test_fuzzborrow(uint256 borrowing_limit) public{
  // uint256 borrowing_limit = address(lending).balance;
  uint256 before_balance = address(this).balance;
  lending.borrow(borrowing_limit);
  uint256 after_balance = address(this).balance;
  assertEq(after_balance-before_balance , borrowing_limit);    
  }

  function test_fuzzrepay() public {
    uint256 borrowing_limit = address(lending).balance;
    uint256 repay_borrow=borrowing_limit;
    uint256 beforebalance = address(this).balance;
    lending.borrow(borrowing_limit);
    lending.repayBorrow(repay_borrow);
    uint256 afterbalance = address(this).balance;
    assertEq(beforebalance , afterbalance);     
  }
      receive() external payable{}
   }

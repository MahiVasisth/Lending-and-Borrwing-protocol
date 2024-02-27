// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract BasicLending {
 
    mapping(address=>uint256)balance;
    mapping(address=>uint256)borrowed_amount;
    
   
function deposit() external payable{
    require(msg.value > 0, "Deposit must be greater than zero");
    balance[msg.sender] += msg.value;
     }
     function withdraw(uint256 amount) external {
        require(amount <= balance[msg.sender],"withdraw amount must be less then or equal to deposited amount");
         balance[msg.sender] -= amount;
         address payable sender = payable(msg.sender);
         sender.transfer(amount);
    }
    function borrow(uint256 amount) external {
     require(amount <= address(this).balance,"Cannot borrow more than available in the pool");
     borrowed_amount[msg.sender] += amount;
      address payable sender = payable(msg.sender);
     sender.transfer(amount);
    }
    function repayBorrow(uint256 amount)external {
    if(amount!=borrowed_amount[msg.sender])
    {
        revert("Require exact eth amount to repay");
    }
    borrowed_amount[msg.sender] = 0;
    }
    }
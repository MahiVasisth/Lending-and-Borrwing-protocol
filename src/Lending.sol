// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions
// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions */

//SPDX-Liense-Identifier:Unlicensed
pragma solidity ^0.8.19;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ILending} from "./interfaces/ILending.sol";
contract Lending is ILending {
    // @notice This is used there to keep track of user balances
    mapping (address=>uint256) s_balanceOf ;
    // @notice This is used to keep track that how much amount borrowed by the user
    mapping(address=>uint256) s_borrowamount;
    using SafeERC20 for IERC20;
    // @notice This is the object of IERC20 
    IERC20 private immutable token;
    // @notice This modifier check that if the user input the zero amount
   modifier check_for_zero_amount(uint256 _amount){
     if(_amount==0)
     {
       revert zero_amount_is_not_valid_there(); 
     }
     _;
   }
    constructor (address _token)
    {
        token = IERC20(_token);
    }

    // @param : _amount is the deposit amount of the user
    // @notice : safeTransferFrom transfer the deposited balance from user address to the contract address.
       
  function deposit(uint256 _amount) external check_for_zero_amount(_amount){
     s_balanceOf[msg.sender]+=_amount;
     token.safeTransfer( address(this), _amount);
    emit depositer(msg.sender , _amount);
  }
  // @notice : This will used by the user to withdraw their amount from the contract.
  function withdraw(uint256 _amount) external check_for_zero_amount(_amount){
    if(s_balanceOf[msg.sender]<_amount)
    {
    revert withdraw_amount_is_greater_then_deposit_amount();
    }
    s_balanceOf[msg.sender]-=_amount;
    token.safeTransfer(msg.sender , _amount);
    emit withdrawer(msg.sender, _amount);
  }
  // @notice : This is used to borrow ethers from the contract . If the borrow amount exceeds the 
//   balance of contract it will revert . 
  function borrow(uint256 _amount) external check_for_zero_amount(_amount){
    if(_amount>address(this).balance)
    {
       revert not_enough_balance_in_contract();
    }
    s_borrowamount[msg.sender]+=_amount;
    token.safeTransfer( msg.sender , _amount);
    emit borrower(msg.sender, _amount);
  }
  // @notice : This is used to repay the amount borrowed by the user.If user repay less then borrowed amount
//    it will revert the function  
  function repay(uint256 _amount) external check_for_zero_amount(_amount){
     if(_amount==s_borrowamount[msg.sender])
     {
        s_borrowamount[msg.sender]=0;
        token.safeTransferFrom(msg.sender,address(this) , _amount);
    }
    else
    {
        revert repay_amount_notequal_to_borrowed_amount();
    }
     emit repayer(msg.sender, _amount);
  }
}
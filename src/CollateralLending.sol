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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ILending} from "./interfaces/ILending.sol";
import {console} from "forge-std/Test.sol";
/**
 * @title Collateral Lending Contract
 * @notice This contract allows users to deposit ERC20 tokens, borrow against them as collateral, and repay their loans.
 * @dev This contract does not handle interest rates or loan durations.
 */
contract CollateralLending is ILending{
    /// @notice Stores the token balances of each user.
    mapping (address=>uint256) s_balanceOf ;
    /// @notice Stores the borrowed token amounts of each user.
    mapping(address=>uint256) s_borrowamount;
    /// @notice The ERC20 token used for lending and borrowing.
    using SafeERC20 for IERC20;
    // IERC20 public token;
    IERC20 public token;
     /// @notice The collateral factor, representing the percentage of tokens required as collateral.
     uint256 public constant collateral_factor = 150 ;
     uint256 public s_totalbalance;
     modifier check_for_zero_amount(uint256 _amount){
        if(_amount==0)
        {
          revert zero_amount_is_not_valid_there(); 
        }
        _;
      }
      
 
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
       }

    /**
     * @notice Allows users to deposit tokens into the contract.
     * @param _amount The amount of tokens to deposit.
     */
    function depositToken(uint256 _amount) external check_for_zero_amount( _amount){
     s_balanceOf[msg.sender]+=_amount;
     s_totalbalance+=_amount;
     token.safeTransfer(address(this),_amount);
    emit depositer(msg.sender , _amount);
    }

    /**
     * @notice Allows users to withdraw their tokens from the contract.
     * @param _amount The amount of tokens to withdraw.
     * @dev Requires that the user has enough balance to withdraw.
     */
    function withdrawToken(uint256 _amount) external check_for_zero_amount(_amount) {
        if(_amount > s_balanceOf[msg.sender]){
        revert withdraw_amount_is_greater_then_deposit_amount();
        }
        s_balanceOf[msg.sender]-=_amount;
        s_totalbalance-=_amount;
        token.safeTransfer(msg.sender ,_amount);
        emit withdrawer(msg.sender ,  _amount);
        }

    /**
     * @notice Allows users to borrow tokens by providing ETH as collateral.
     * @param _tokenAmount The amount of tokens to borrow.
     * @dev Requires that the user provides enough ETH as collateral and that the contract has enough tokens to lend.
     */
    function borrowTokenWithCollateral(uint256 _tokenAmount) external payable check_for_zero_amount(_tokenAmount) {
        if(msg.value < _tokenAmount * collateral_factor / 100){
            revert not_enough_collateral_provided();
        }
      if(_tokenAmount > address(this).balance){
        revert not_enough_balance_in_contract();
     }
     s_borrowamount[msg.sender] += _tokenAmount;
     token.safeTransfer( msg.sender , _tokenAmount);
     emit borrower(msg.sender , _tokenAmount);
    }

    /**
     * @notice Allows users to repay their borrowed tokens.
     * @param _tokenAmount The amount of tokens to repay.
     * @dev Requires that the user has borrowed at least the amount they are trying to repay.
     */
    function repayToken(uint256 _tokenAmount) external check_for_zero_amount(_tokenAmount){
       if(s_borrowamount[msg.sender]<_tokenAmount)
       {
         revert you_are_repay_more_then_borrow();
       }       
       s_borrowamount[msg.sender]-=_tokenAmount;
       token.safeTransferFrom(msg.sender , address(this), _tokenAmount);
       token.safeTransfer(msg.sender , _tokenAmount * collateral_factor / 100);
       emit repayer(msg.sender , _tokenAmount);
    }

    /**
     * @notice Allows for the liquidation of a borrower's collateral if they fail to maintain the required collateral factor.
     * @param borrower The address of the borrower.
     * @param _tokenAmount The amount of tokens to be liquidated.
     * @dev Requires that the borrower's collateral is less than the required amount and that they have borrowed the specified token amount.
     */
    function liquidate(address borrower, uint256 _tokenAmount) external payable check_for_zero_amount(_tokenAmount) {
        if(msg.value > _tokenAmount * collateral_factor / 100){
            revert already_have_enough_collateral_provided();
        }
       if(_tokenAmount<s_borrowamount[msg.sender] ){
         revert borrowamountmustbelessthenliquidateamount();
       }
       s_borrowamount[msg.sender]-=_tokenAmount; 
       token.safeTransfer(address(this), _tokenAmount);
       token.safeTransfer(msg.sender , msg.value);
        // emit liquidate(msg.sender , _tokenAmount);
    }
receive() external payable {}
}
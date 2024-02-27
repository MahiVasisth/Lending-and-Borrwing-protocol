//SPDX-Liense-Identifier:Unlicensed
pragma solidity ^0.8.20;
contract ILending {
    // events
    event depositer(address sender , uint256 amount);
    event withdrawer(address receiver , uint256 amount);
    event borrower(address borrower , uint256 amount);
    event repayer(address sender,uint256 amount);
    // event liquidate(address sender , uint256 amount);
   // errors
   error zero_amount_is_not_valid_there();
   error zero_amount_passed();
   error withdraw_amount_is_greater_then_deposit_amount();
   error not_enough_balance_in_contract();
   error repay_amount_notequal_to_borrowed_amount();
   error not_enough_collateral_provided();
   error already_have_enough_collateral_provided();
   error borrowamountmustbelessthenliquidateamount();
   error you_are_repay_more_then_borrow();
   error repay_amount_notequal_to_borrowed_amount();

} 
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UCLoan {
    /**
    Counterparties in the loan
     */
    //Guarantor
    address guarantor;
    //Borrower
    address borrower;
    //Lender
    address lender;
    //mapping of addys to amount sent
    mapping(address => uint256) amountFundedByAddress;
    /**
    Variables of the loan
     */

    //storage
    uint256 public amountBorrowed;
    //storage Immutable Total Amount to Be Repaid
    uint256 public immutable amountToBeRepaid;
    //storage Amount remaining to be repaid
    uint256 public amountLeft2Pay;
    //requiredCollateralAmount to start
    uint256 public requiredCollateralAmount;
    //loanActive
    bool public isLoanActive;

    constructor(
        address _lender,
        address _borrower,
        address _guarantor,
        uint16 _interestRate,
        uint256 _amountBorrowed,
        uint256 _requiredCollateral
    ) payable {
        lender = _lender;
        borrower = _borrower;
        guarantor = _guarantor;
        amountToBeRepaid = _interestRate * _amountBorrowed + _amountBorrowed;
        requiredCollateralAmount = _requiredCollateral;
    }

    modifier onlyGuarantor() {
        require(msg.sender == guarantor, "is not gurantor");
        _;
    }

    modifier onlyBorrower() {
        require(msg.sender == borrower, "is not borrower");
        _;
    }

    modifier onlyLender() {
        require(msg.sender == lender, "is not lender");
        _;
    }

    /**
    Cancels the loan in case the borrow changes mind in last minute
    Or if borrower has not supplied enough collateral
     */
    function cancelLoan() public onlyLender {
        require(
            amountFundedByAddress[borrower] != requiredCollateralAmount,
            "Loan has already started"
        );
        require(!isLoanActive, "Loan started already bro");
        emergencyWithdraw();
    }

    /**
    Emergency withdraw function used if anything goes wrong with the loan
    Only used internally no one can call directly
    Only to be used if the loan has not been started because then money is in flux
    Gives all money back at current state starting with money for the lender
    Then money for the guarantor
    Then money for the borrower
    Then selfdestructs and returns any leftovers to the lender
     */
    function emergencyWithdraw() internal {
        (bool callSuccess, ) = payable(lender).call{
            value: amountFundedByAddress[lender]
        }("");
        require(callSuccess, "Call failed");
        (bool call3Success, ) = payable(guarantor).call{
            value: amountFundedByAddress[guarantor]
        }("");
        require(call3Success, "Call failed");
        (bool call2Success, ) = payable(borrower).call{
            value: amountFundedByAddress[borrower]
        }("");
        require(call2Success, "Call failed");
        selfdestruct(payable(lender));
    }

    /**
    What the borrower sends if they agree to the terms of the loan
     */
    function acceptLoanAndPayCollateral() external payable onlyBorrower {
        require(msg.value <= requiredCollateralAmount);
        amountFundedByAddress[borrower] += msg.value;
        isLoanActive = true;
    }

    /**
    What the borrower sends if the deny the loan
     */
    function denyLoan() external onlyBorrower {
        require(!isLoanActive, "Loan already started");
        emergencyWithdraw();
    }
}
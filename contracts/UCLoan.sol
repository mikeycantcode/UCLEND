//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Brought to you by mikeyLabz...

/**
This UCLoan is created individually each time a loan is made using the website
or UCLoanFactory. 

---Starting the loan

When it's created, it has to be funded with the lenders funds in order to be created or else it reverts
At creation, the variables are fed from the UCLoanFactory into the individual loan, and the individual loan 
is added to a data structure in UCLoanFactory

Before the borrower accepts, the starting date of the loan does not increment and the lender can call
cancelLoan() at any time. cancelLoan() ends the loan and gives the lender their funds back.

The borrower can then either acceptLoanAndPayCollateral() or denyLoan(). denyLoan() ends the loan and gives the lender their
funds back, and acceptLoanAndPayCollateral() begins the loan, but only if the borrower pays the collateral along with the accept.

---During the loan

Once the loan is started, the remaining variable are initialized such as the starting block number (startdate), and the isLoanActive boolean is set to true
thus starting the loan.

Now after accepting, the borrower can withdraw the funds from the UCLoan contract. The borrower can also start making payments to repay their loan
If a nonzero guarantor is specified, the guarantor can help pay for the loan in case of nonpayment, or a missed payment from the borrower

During the loan the lender is allowed to withdraw payments from the loan as they come in thru withdrawLender()

---Finishing the loan

There are 3 possible outcomes of a loan.

Loan is paid by the time the loan ends - no bad debt, loan closes and is turned off/selfdestructed
In this case -
bad debt == 0 
lender is repaid everything
borrower is repaid collateral
loan selfdestructs
everyone is happy

Loan is not paid off by the time theloan ends, but the lender allows the borrower to keep making payments
bad debt > 0
lender calls keepAlive()
allows borrower to keep making payments 
lender is allowed to take collateral + whatever has already been paid

Loan is not paid off by the time the loan ends, and the lender decides to take it offchain to arbitrage or collections or a lawsuit
bad debt > 0
lender calls badLoan()
the state of the loan is frozen
no more payments
lender withdraws whatever is in collateral + whatever has already been paid
can query the blockchain for all of the informatio pertaining to the loan



 */

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
    //due date
    uint256 public dueDate;
    //date at which loan was started
    uint256 public startDate;

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

    modifier isActiveLoan() {
        require(isLoanActive, "");
        _;
    }

    constructor(
        address _lender,
        address _borrower,
        address _guarantor,
        uint16 _interestRate,
        uint256 _amountBorrowed,
        uint256 _requiredCollateral,
        uint256 _dueDate
    ) payable {
        dueDate = _dueDate;
        lender = _lender;
        borrower = _borrower;
        guarantor = _guarantor;
        amountToBeRepaid = _interestRate * _amountBorrowed + _amountBorrowed;
        requiredCollateralAmount = _requiredCollateral;
        amountFundedByAddress[lender] += msg.value;
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
    Recalculates the amount left to pay off the loan
     */
    function recalculateAmountLeft2Pay() internal {
        amountLeft2Pay =
            amountToBeRepaid -
            amountFundedByAddress[borrower] -
            amountFundedByAddress[guarantor];
    }

    /**
    Cancels the loan in case the borrow changes mind in last minute
    Or if borrower has not supplied enough collateral
     */
    function cancelLoan() external onlyLender {
        require(
            amountFundedByAddress[borrower] != requiredCollateralAmount,
            "Loan has already started"
        );
        require(!isLoanActive, "Loan started already bro");
        emergencyWithdraw();
    }

    /**
    What the borrower sends if they agree to the terms of the loan
    Step by step it:
    requires that the borrower has sent in the required amount of collateral
    adds the collateral amount to amountfundedbyaddress
    calculates the amount left to pay
    makes the loan active
     */
    function acceptLoanAndPayCollateral()
        external
        payable
        onlyBorrower
        returns (uint256)
    {
        require(msg.value >= requiredCollateralAmount);
        amountFundedByAddress[borrower] += msg.value;
        startDate = block.number;
        recalculateAmountLeft2Pay();
        isLoanActive = true;
        return startDate;
    }

    /**
    What the borrower sends if the deny the loan
     */
    function denyLoan() external onlyBorrower {
        require(!isLoanActive, "Loan already started");
        emergencyWithdraw();
    }

    /**
    Function that allows the borrower to withdraw the amount borrowed
     */
    function withdrawBorrowed() external onlyBorrower isActiveLoan {
        (bool callSuccess, ) = payable(borrower).call{
            value: amountFundedByAddress[lender]
        }("");
        require(callSuccess, "Call failed");
    }

    /**
    Allows the guarantor to add collateral/repay the loan
     */
    function guarantorPayOffLoan() external payable onlyGuarantor isActiveLoan {
        require(msg.value >= 0);
        amountFundedByAddress[guarantor] += msg.value;
        recalculateAmountLeft2Pay();
    }

    /**
    Allows the borrower to pay back the loan
     */
    function borrowerPayOffLoan() external payable onlyBorrower isActiveLoan {
        require(msg.value >= 0);
        amountFundedByAddress[borrower] += msg.value;
        recalculateAmountLeft2Pay();
    }

    /**
    Allows the lender to withdraw the funds that he has a right to
    (not collateral before the due date) (only the amounts that r paid back currently)
    (after the due date, everything in the contract is fair game)
    (if not everything is paid back yet then the remianing shows up as bad debt and the 
    two parties can arbitrate offchain)
     */

    //--------viewfunctions------------

    /**
    
     */
    function viewDebt() external view returns (uint256, uint8) {}
}

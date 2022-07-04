//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//I tried to make this as much as similar to a loan as possible, but it is slowly looking like less of a loan and more of some kind of
//fixed expiry financial product. Idk though im not a finance nerd so like it is what it is.
import "./UCLoan.sol";

contract UCLoanFactory {
    UCLoan[] ucloans;
    mapping(address => UCLoan) lender2Loan;
    mapping(address => UCLoan) borrower2Loan;
    mapping(address => UCLoan) guarantor2Loan;

    constructor() {}

    //set the guarantor to the zero address if you watn to not have a guarantor
    //lender ALWAYS drafts up the contract, sends the contract to the borrower
    function newLoan(
        address _borrower,
        address _guarantor,
        uint16 _interestRate, 
        uint256 _amountBorrowed,
        uint256 _requiredCollateral,
        uint256 _dueDate
    ) external payable returns (address) {
        UCLoan ucLoan = (new UCLoan){value: msg.value}(
            msg.sender,
            _borrower,
            _guarantor,
            _interestRate,
            _amountBorrowed,
            _requiredCollateral,
            _dueDate
        );
        ucloans.push(ucLoan);
        lender2Loan[msg.sender] = ucLoan;
        borrower2Loan[_borrower] = ucLoan;
        guarantor2Loan[_guarantor] = ucLoan;
        return address(ucLoan);
    }

    //getLoan

    //viewfunctions

    //view the amount left to pay for a certain address
    //if the function returns 404 it means that there are no loans found with associated account
    function viewAddressOfLender2Loan(address _address)
        external
        view
        returns (address)
    {
        if (lender2Loan[_address].viewLender() != address(0x0)) {
            return address(lender2Loan[_address]);
        } else {
            return address(0x0);
        }
    }

    //borrower2loaln
    function viewAddressOfBorrower2Loan(address _address)
        external
        view
        returns (address)
    {
        if (borrower2Loan[_address].viewLender() != address(0x0)) {
            return address(borrower2Loan[_address]);
        } else {
            return address(0x0);
        }
    }

    //guraantor
    function viewAddressOfGuarantor2Loan(address _address)
        external
        view
        returns (address)
    {
        if (guarantor2Loan[_address].viewLender() != address(0x0)) {
            return address(guarantor2Loan[_address]);
        } else {
            return address(0x0);
        }
    }

    /*


            } else if (borrower2Loan[_address].viewLender() != address(0x0)) {
            return address(borrower2Loan[_address]);
        } else if (guarantor2Loan[_address].viewLender() != address(0x0)) {
            return address(guarantor2Loan[_address]);
        }
        return address(0x0);

        */
}

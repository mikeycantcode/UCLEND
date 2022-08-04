//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//I tried to make this as much as similar to a loan as possible, but it is slowly looking like less of a loan and more of some kind of
//fixed expiry financial product. Idk though im not a finance nerd so like it is what it is.
import "./UCLoan.sol";

contract UCLoanFactory {
    LoanFinder[] ucloans;

    struct LoanFinder {
        address loan;
        address borrower;
        address lender;
        address guarantor;
    }

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
        address _lender = msg.sender;
        LoanFinder memory loanFinder = LoanFinder(
            address(ucLoan),
            _borrower,
            _lender,
            _guarantor
        );
        ucloans.push(loanFinder);
        return address(ucLoan);
    }

    //getLoan

    //viewfunctions

    //view the amount left to pay for a certain address
    //if the function returns 404 it means that there are no loans found with associated account
    function viewAddressOfLender2Loan(address _address)
        external
        view
        returns (address[] memory)
    {
        address[] memory ans = new address[](10);
        uint8 j = 0;
        for (uint32 i = 0; i < ucloans.length; i++) {
            if (ucloans[i].lender == _address) {
                ans[j] = (ucloans[i].loan);
                j++;
            }
        }
        return ans;
    }

    //borrower2loaln
    function viewAddressOfBorrower2Loan(address _address)
        external
        view
        returns (address[] memory)
    {
        address[] memory ans = new address[](10);
        uint8 j = 0;
        for (uint32 i = 0; i < ucloans.length; i++) {
            if (ucloans[i].borrower == _address) {
                ans[j] = (ucloans[i].loan);
                j++;
            }
        }
        return ans;
    }

    //guraantor
    function viewAddressOfGuarantor2Loan(address _address)
        external
        view
        returns (address[] memory)
    {
        address[] memory ans = new address[](10);
        uint8 j = 0;
        for (uint32 i = 0; i < ucloans.length; i++) {
            if (ucloans[i].guarantor == _address) {
                ans[j] = (ucloans[i].loan);
                j++;
            }
        }
        return ans;
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

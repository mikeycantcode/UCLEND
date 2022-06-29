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
        borrower2Loan[ucLoan.viewBorrower()] = ucLoan;
        guarantor2Loan[ucLoan.viewGuarantor()] = ucLoan;
        return address(ucLoan);
    }
}

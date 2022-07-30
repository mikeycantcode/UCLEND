# UCLEND - a P2P Loan Platform on the [EVM] blockchain

A small project that uses the blockchain to make a p2p loan.

If you trust your counterparty and guarantor, this loan tool can make everything simplified and easy to use!

This is meant for loans where you know who your counterparty is and have legal agreements dealing with what would happen in the case of bad debt available

Website / frontend coming soon!

-------
<<<<<<< HEAD
=======

To test on a local network run

```
yarn hardhat node
yarn hardhat test
```

To deploy run `yarn hardhat deploy --network`

-------

This platform works by the lender creating a loan using the `newLoan()` function of the ucLoanFactory contract. 
This creates an individual ucLoan contract, which has functions to manipulate the loan such as `acceptLoanAndPayCollateral()`, `borrowerPayOffLoan()`, and `marginCall()`. 
Once the loan is over and paid off, the individual ucLoan is selfdestructed and gas returned to the lender.

The files should be well documented if you have any questions.

--------





>>>>>>> 3f8a2d4f0d710bf7391bdd1d8bf875747e1984cf

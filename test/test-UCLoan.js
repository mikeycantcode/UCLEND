// const { inputToConfig } = require("@ethereum-waffle/compiler");
// const { getContractFactory } = require("@nomiclabs/hardhat-ethers/types");
// const { expect } = require("chai");
// const { ethers, getNamedAccounts } = require("hardhat");

// /**
//  * Tests the UCLoan.sol file
//  * tests if functions are working as intended, and that
//  * no wierd errors are ocurring
//  */

// describe("UCLoan", async function () {
//     /**
//      * 
//      */
//     let ucLoan
//     let lender
//     let borrower
//     let guarantor
//     let effectiveInterestRate

//     /**
//      * This initial part sets up the test fixture for the remaining
//      * tests
//      * 10**18 is 1eth worth of wei
//      */
//     beforeEach(async function () {
//         //set deployer from getnamedaccounts
//         lender = (await getNamedAccounts()).deployer
//         borrower = await getNamedAccounts[2]
//         guarantor = await getNamedAccounts[3]
//         //10% effective interest rate
//         effectiveInterestRate = 10
//         //THIS PART DEPLOYS!!!!!!!!!!
//         //RUNS ALL OF YOUR DEPLOY SCRIPTS
//         await deployments.fixture(["all"])
//         //this gets the PREDEPLOYED contract
//         ucLoan = await ethers.getContract("UCLoan", lender, borrower, guarantor, 10 ** 18, 4 ** 18, 10)
//     })


//     /**
//      * This tests the constructor of the loan to see if the variables are 
//      * initialized properly
//      */
//     describe("constructor", async function () {
//         it("initializes the variables into storage", async function () {

//         })

//         it("calculates the effective interest rate correctly", async function () {

//         })

//         it("gets the funds idk bruh", async function () {

//         })
//     })
// })

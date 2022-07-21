const { inputToConfig } = require("@ethereum-waffle/compiler");
const { getContractFactory } = require("@nomiclabs/hardhat-ethers/types");
const { expect, assert } = require("chai");
const { Contract } = require("ethers");
const { ethers, getNamedAccounts } = require("hardhat");

/**
 * Tests the UCLoanFactory.sol file
 * tests if functions are working as intended, and that
 * no wierd errors are ocurring
 */
describe("UCLoanFactory fuck i decided to test everything", async function () {
    /**
     * 
     */
    let ucLoanFactory
    let lender
    let borrower
    let guarantor
    let effectiveInterestRate

    /**
     * This initial part sets up the test fixture for the remaining
     * tests
     * 10**18 is 1eth worth of wei
     */
    beforeEach(async function () {
        //set deployer from getnamedaccounts

        lender = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
        borrower = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
        guarantor = "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
        //10% effective interest rate
        effectiveInterestRate = "10"
        //THIS PART DEPLOYS!!!!!!!!!!
        //RUNS ALL OF YOUR DEPLOY SCRIPTS
        await deployments.fixture(["all"])
        //this gets the PREDEPLOYED contract
        //, lender, borrower, guarantor, 10 ** 18, 4 ** 18, 10
        ucLoanFactory = await ethers.getContract("UCLoanFactory")
    })


    /**
     * This tests the constructor of the loan to see if the variables are 
     * initialized properly
     */
    let txResponse
    describe("newLoan()", async function () {
        beforeEach(async function () {
            console.log("error")
            const sendValue = ethers.utils.parseEther("10.0003")
            //ethers.utils.parseEther(0.4) ethers.utils is for some reason not working its so wierd
            txResponse = await ucLoanFactory.newLoan(borrower, guarantor, effectiveInterestRate, "1000000000000000000", "400000000000000000", "20", { value: sendValue })
            console.log("before each works")
        })

        it("creates a UCLoan object", async function () {
            assert.notEqual(txResponse, "0x0000000000000000000000000000000000000000")
            console.log("first assertion works")
            newUcLoan = await ethers.getContractAt("UCLoan", txResponse)
            console.log("---")
        })

        it("adds to the lender mapping", async function () {
            let address = await ucLoanFactory.viewAddressOfLender2Loan(lender)
            console.log(address)

        })

        it("adds to the borrower mapping", async function () {
            let address = await ucLoanFactory.viewAddressOfBorrower2Loan(borrower)
            console.log(address)
        })

        it("adds to the guarantor mapping", async function () {
            let address = await ucLoanFactory.viewAddressOfGuarantor2Loan(guarantor)
            console.log(address)
        })

        it("is the newloan functional?", async function () {
            let address = await ucLoanFactory.viewAddressOfLender2Loan(lender)
            console.log(address)
            ucLoan = await ethers.getContractAt("UCLoan", address)
            console.log(ucLoan)
            assert.equal(await ucLoan.viewLender(), lender)
            await ucLoan.cancelLoan()
            assert.equal(ucLoan.lender = undefined)
        })

        it("can accept the newloan once created from the ucloanfactory", async function () {
            let address = await ucLoanFactory.viewAddressOfLender2Loan(lender)
            ucLoan = await ethers.getContractAt("UCLoan", address)
            //ucLoan.connect.
        })
    })
})
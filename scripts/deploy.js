const hre = require("hardhat");
//going to replace this with a deploy folder as soon as i figure out what the fuck I fucked up on in the fucking fucker dev environment
async function main() {
  const ucLoanCode = await hre.ethers.getContractFactory("UCLoan");
  const ucLoan = await Greeter.deploy("Hello, Hardhat!");

  await ucLoan.deployed();

  console.log("ucloan active @ ", ucLoan.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

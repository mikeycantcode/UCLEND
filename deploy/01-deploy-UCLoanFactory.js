//imports

const { network } = require("hardhat")

//call default function async anonymous
//hre is the hardhat runtime environment
module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    //getting preliminary data from the hardhat runtime enviroment
    console.log(`[deploy-01] Preparing to deploy UCLoanFactory...`)
    const { deploy, log } = deployments
    //this is where deployer is grabbed
    const { deployer } = await getNamedAccounts()


    const fundMe = await deploy("UCLoanFactory", {
        from: deployer,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1
    })

    log("------deploy-01-ended---------")
}
module.exports.tags = ["all", "factory"]
const hre = require('hardhat')

async function main() {
  // get the compiled contract ( or compiling? )
  const contractFactory = await hre.ethers.getContractFactory("WavePortal")

  // deploy the contract on a local chain
  const contract = await contractFactory.deploy()

  // wait until the deployment is finished
  await contract.deployed()

  console.log("Contract address: ", contract.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

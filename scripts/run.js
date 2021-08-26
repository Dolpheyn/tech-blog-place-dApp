const hre = require('hardhat')

async function main() {
  // get the compiled contract ( or compiling? )
  const contractFactory = await hre.ethers.getContractFactory("WavePortal")

  // deploy the contract on a local chain
  const contract = await contractFactory.deploy()

  // wait until the deployment is finished
  await contract.deployed()

  console.log("Contract deployed at address: ", contract.address)

  console.log("-------------")

  console.log("Calling `contract.getTotalWaves()`")
  let count = await contract.getTotalWaves()
  console.log(`Total wave: ${count.toNumber()}`)

  console.log("Calling `contract.wave()`")
  await contract.wave()

  console.log("Calling `contract.getTotalWaves()`")
  count = await contract.getTotalWaves()
  console.log(`Total wave: ${count.toNumber()}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

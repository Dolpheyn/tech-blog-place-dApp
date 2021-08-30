const hre = require('hardhat')

async function main() {
  // get the compiled contract ( or compiling? )
  const contractFactory = await hre.ethers.getContractFactory("TechBlogPlace")

  // deploy the contract on a local chain
  const contract = await contractFactory.deploy()

  // wait until the deployment is finished
  await contract.deployed()

  console.log("Contract deployed at address: ", contract.address)

  console.log("-------------")

  console.log("Calling `contract.getTotalRecommendations()`")
  let count = await contract.getTotalRecommendations()
  console.log(`Total Recommendations: ${count.toNumber()}`)

  console.log("Calling `contract.recommend()`")
  await contract.recommend("https://dolpheyn.github.io")

  console.log("Calling `contract.getTotalRecommendations()`")
  count = await contract.getTotalRecommendations()
  console.log(`Total Recommendation: ${count.toNumber()}`)

  const allRecommendations = await contract.getAllRecommendations()
  console.log(allRecommendations)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

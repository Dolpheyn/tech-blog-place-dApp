const {assert} = require('chai')
const hre = require('hardhat')

async function main() {
  // get the compiled contract ( or compiling? )
  const contractFactory = await hre.ethers.getContractFactory("TechBlogPlace")

  // deploy the contract on a local chain
  // and fund some eth into it
  const contract = await contractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1")
  })

  // wait until the deployment is finished
  await contract.deployed()

  console.log("Contract deployed at address: ", contract.address)

  let contractBalance = await hre.ethers.provider.getBalance(contract.address)
  console.log(`Contract balance: ${hre.ethers.utils.formatEther(contractBalance)}`)

  console.log("-------------")

  console.log("Calling `contract.getTotalRecommendations()`")
  let count = await contract.getTotalRecommendations()
  console.log(`Total Recommendations: ${count.toNumber()}`)

  console.log("-------------")

  for(const i of [1, 2]) {
    console.log("Calling `contract.recommend()`")

    try {
      await contract.recommend("https://dolpheyn.github.io")
    } catch(e) {
      assert(i == 2)
      console.log('Successfully error for second message!')
    }

    contractBalance = await hre.ethers.provider.getBalance(contract.address)
    console.log(`Contract balance: ${hre.ethers.utils.formatEther(contractBalance)}`)

    console.log("Calling `contract.getTotalRecommendations()`")
    count = await contract.getTotalRecommendations()
    console.log(`Total Recommendation: ${count.toNumber()}`)
  }

  const allRecommendations = await contract.getAllRecommendations()
  console.log(allRecommendations)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

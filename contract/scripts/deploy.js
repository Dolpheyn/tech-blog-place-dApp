async function main() {
  const [deployer] = await ethers.getSigners()
  const contractFactory = await ethers.getContractFactory('TechBlogPlace')
  const contract = await contractFactory.deploy({
    value: ethers.utils.parseEther("0.1"), // Fund the contract some eth
  })
  await contract.deployed()
  console.log(`Deployed at address: ${contract.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.stack)
    process.exit(1)
  })


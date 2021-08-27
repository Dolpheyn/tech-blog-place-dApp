require("@nomiclabs/hardhat-waffle")
require('dotenv').config()

module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: process.env.ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    }
  }
};

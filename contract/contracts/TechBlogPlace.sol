// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract TechBlogPlace {
  uint private seed;

  struct Recommendation {
    address recommender;
    string blog;
    uint timestamp;
  }

  Recommendation[] recommendations;

  event NewRecommendation(address indexed from, uint timestamp, string message);

  // Maps address to uint(which is the timestamp) that stores the last time each
  // user sent a recommendation.
  mapping(address => uint) public lastRecommendationTime;

  // The `payable` syntax allows overriding of the contract's value
  constructor() payable {
    console.log("Constructor invoked!");
  }

  function recommend(string memory _blog) public {
    require(lastRecommendationTime[msg.sender] + 5 minutes < block.timestamp,
           "Wait 5m before recommending again.");

    lastRecommendationTime[msg.sender] = block.timestamp;

    console.log("%s recommended blog %s", msg.sender, _blog);

    // Push a `Recommendation` instance into the `recommendations` list.
    recommendations.push(Recommendation(msg.sender, _blog, block.timestamp));

    // Generate a pseudo random number in the range 100.
    uint randomNumber = (block.difficulty + block.timestamp + seed) % 100;
    console.log("Random # generated: %s", randomNumber);

    // Set seed to generated random number for next wave.
    seed = randomNumber;

    if(randomNumber < 50) {
      uint prizeAmount = 0.001 ether;

      // We need the balance of this contract to be more than the prize amount.
      // `require` is like `assert`
      require(prizeAmount <= address(this).balance,
              "Trying to withdraw more money than the contract has.");

      // Send the sender some eth and get result
      (bool success,) = (msg.sender).call{value: prizeAmount}("");

      // If success == false, report failure
      require(success, "Failed to withdraw money from contract.");
    }

    // Clients can listen for events emitted from a contract.
    emit NewRecommendation(msg.sender, block.timestamp, _blog);
  }

  function getAllRecommendations() view public returns (Recommendation[] memory) {
    return recommendations;
  }

  function getTotalRecommendations() view public returns (uint) {
    return recommendations.length;
  }
}

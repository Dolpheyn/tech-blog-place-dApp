// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract TechBlogPlace {
  event NewRecommendation(address indexed from, uint timestamp, string message);

  struct Recommendation {
    address recommender;
    string blog;
    uint timestamp;
  }

  Recommendation[] recommendations;

  // The `payable` syntax allows overriding of the contract's value
  constructor() payable {
    console.log("Constructor invoked!");
  }

  function recommend(string memory _blog) public {
    console.log("%s recommended blog %s", msg.sender, _blog);

    // Push a `Recommendation` instance into the `recommendations` list.
    recommendations.push(Recommendation(msg.sender, _blog, block.timestamp));

    // Clients can listen for events emitted from a contract.
    emit NewRecommendation(msg.sender, block.timestamp, _blog);

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

  function getAllRecommendations() view public returns (Recommendation[] memory) {
    return recommendations;
  }

  function getTotalRecommendations() view public returns (uint) {
    return recommendations.length;
  }
}

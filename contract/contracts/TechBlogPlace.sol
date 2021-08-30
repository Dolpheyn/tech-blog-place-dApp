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

  constructor() {
    console.log("Constructor invoked!");
  }

  function recommend(string memory _blog) public {
    console.log("%s recommended blog %s", msg.sender, _blog);

    // Push a `Recommendation` instance into the `recommendations` list.
    recommendations.push(Recommendation(msg.sender, _blog, block.timestamp));

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

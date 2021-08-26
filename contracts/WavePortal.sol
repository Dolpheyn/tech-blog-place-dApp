// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
  uint totalWaves;

  constructor() {
    console.log("Hello, Dolpheyn!");
  }

  function wave() public {
    totalWaves += 1;
    console.log("%s waved", msg.sender);
  }

  function getTotalWaves() view public returns (uint) {
    return totalWaves;
  }
}

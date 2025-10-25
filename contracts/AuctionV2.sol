
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AuctionV1.sol";

contract AuctionV2 is AuctionV1 {
    string public greeting;

    function sayHi(string memory _greeting) public {
        greeting = _greeting;
    }

    function getGreeting() public view returns (string memory) {
        return greeting;
    }
}

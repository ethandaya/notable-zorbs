// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ZeckMetadataRenderer.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

}

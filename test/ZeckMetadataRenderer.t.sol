// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ZeckMetadataRenderer.sol";

contract CounterTest is Test {
    IMetadataRenderer public renderer;

    function setUp() public {
        renderer = new ZeckMetadataRenderer();
    }

    function test_tokenURI() public {
        assertEq(renderer.tokenURI(0), "TEST");
    }
}

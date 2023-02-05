// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import { IMetadataRenderer } from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";

contract ZeckMetadataRenderer is IMetadataRenderer {
    function tokenURI(uint256) external view returns (string memory){
        return "TEST";
    }
    function contractURI() external view returns (string memory){
        return "TEST";
    }
    function initializeWithData(bytes memory initData) external {
        // do nothing
    }
}

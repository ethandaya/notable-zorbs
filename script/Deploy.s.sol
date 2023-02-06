// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "zora-drops-contracts/ZoraNFTCreatorV1.sol";
import "zora-drops-contracts/ERC721Drop.sol";
import "../src/NotableZorbsMetadataRenderer.sol";

contract Deploy is Script {
    function run() public {
        console.log("Starting ---");

        ZoraNFTCreatorV1 creator = ZoraNFTCreatorV1(
            payable(address(vm.envAddress("ZORA_NFT_CREATOR_ADDRESS")))
        );

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint16 ROYALTY_BPS = 250;

        ERC721Drop drop = ERC721Drop(
            payable(address(vm.envAddress("EDITION_ADDRESS")))
        );

        NotableZorbsMetadataRenderer renderer = new NotableZorbsMetadataRenderer(
                "Notable Zorb",
                "This zorb may or may not be notable.",
                "ipfs:///bafkreif36vetz6ayldjo252lzfpustwpu7myzhfe3x3ptepmxa6mfga6pe",
                Strings.toString(250),
                string(abi.encodePacked(msg.sender)),
                "https://notablezorbs.xyz",
                payable(address(vm.envAddress("EDITION_ADDRESS")))
            );

        drop.setMetadataRenderer(renderer, "");

        vm.stopBroadcast();
    }
}

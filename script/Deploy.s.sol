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

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint16 ROYALTY_BPS = 250;

        ERC721Drop drop = ERC721Drop(
            payable(address(vm.envAddress("EDITION_ADDRESS")))
        );

        NotableZorbsMetadataRenderer renderer = new NotableZorbsMetadataRenderer(
                "Notable Zorb",
                "This zorb may or may not be notable.",
                "ipfs://bafybeibvflhws7clzdeqlpoie65dfgx62thoatry6oayv56loqheb3xqka",
                Strings.toString(ROYALTY_BPS),
                "",
                "https://notablezorbs.xyz",
                payable(address(vm.envAddress("EDITION_ADDRESS")))
            );

        drop.setMetadataRenderer(renderer, "");

        vm.stopBroadcast();
    }
}

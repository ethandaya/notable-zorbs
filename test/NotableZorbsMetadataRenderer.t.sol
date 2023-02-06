// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "zora-drops-contracts/ZoraNFTCreatorV1.sol";
import "zora-drops-contracts/interfaces/IERC721Drop.sol";
import "zora-drops-contracts/ZoraNFTCreatorProxy.sol";
import "zora-drops-contracts/ZoraFeeManager.sol";
import "zora-drops-contracts/FactoryUpgradeGate.sol";
import { ZorbNFT } from "zorb/ZorbNFT.sol";
import {NotableZorbsMetadataRenderer }from "../src/NotableZorbsMetadataRenderer.sol";

contract NotableZorbsTest is Test {
    ERC721 public zorb;
    NotableZorbsMetadataRenderer public renderer;

    function setUp_Zora() public {
        vm.prank(DEFAULT_ZORA_DAO_ADDRESS);
        ZoraFeeManager feeManager = new ZoraFeeManager(
            500,
            DEFAULT_ZORA_DAO_ADDRESS
        );
        vm.prank(DEFAULT_ZORA_DAO_ADDRESS);
        dropImpl = new ERC721Drop(
            feeManager,
            address(1234),
            FactoryUpgradeGate(address(0)),
            address(0)
        );
        editionMetadataRenderer = new EditionMetadataRenderer();
        dropMetadataRenderer = new DropMetadataRenderer();
        ZoraNFTCreatorV1 impl = new ZoraNFTCreatorV1(
            address(dropImpl),
            editionMetadataRenderer,
            dropMetadataRenderer
        );
        creator = ZoraNFTCreatorV1(
            address(
                new ZoraNFTCreatorProxy(
                    address(impl),
                    abi.encodeWithSelector(ZoraNFTCreatorV1.initialize.selector)
                )
            )
        );
    }

    function setUp() public {
        renderer = new NotableZorbsMetadataRenderer();
        zorb = new ZorbNFT();
    }


}

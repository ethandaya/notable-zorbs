// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "zora-drops-contracts/ZoraNFTCreatorV1.sol";
import "zora-drops-contracts/interfaces/IERC721Drop.sol";
import "zora-drops-contracts/ZoraNFTCreatorProxy.sol";
import "zora-drops-contracts/ZoraFeeManager.sol";
import "zora-drops-contracts/FactoryUpgradeGate.sol";
import {NotableZorbsMetadataRenderer} from "../src/NotableZorbsMetadataRenderer.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

contract NotableZorbsTest is Test {
    // @notice Notable Constants
    ERC721Drop drop;
    NotableZorbsMetadataRenderer public renderer;
    address payable public constant OWNER_ADDRESS = payable(address(42069));
    address payable public constant MINTER_ADDRESS = payable(address(69420));

    // @notice Zora Constants
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address payable public constant DEFAULT_ZORA_DAO_ADDRESS =
        payable(address(0x999));
    ERC721Drop public dropImpl;
    ZoraNFTCreatorV1 public creator;
    EditionMetadataRenderer public editionMetadataRenderer;
    DropMetadataRenderer public dropMetadataRenderer;

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

    function setUp_Drop() public {
        string memory name = "Notable Zorb";
        uint16 ROYALTY_BPS = 250;
        address deployedDrop = creator.createEdition(
            string(abi.encodePacked(name, "s")),
            "NZORB",
            type(uint64).max,
            ROYALTY_BPS,
            OWNER_ADDRESS,
            OWNER_ADDRESS,
            IERC721Drop.SalesConfiguration({
                publicSaleStart: uint64(block.timestamp),
                publicSaleEnd: uint64(block.timestamp + 3 days),
                presaleStart: 0,
                presaleEnd: 0,
                publicSalePrice: 0.0069 ether,
                maxSalePurchasePerAddress: 0,
                presaleMerkleRoot: bytes32(0)
            }),
            "description",
            "imageURI",
            "animationURI"
        );
        drop = ERC721Drop(payable(deployedDrop));
        renderer = new NotableZorbsMetadataRenderer(
            name,
            "This Zorb may or may not be notable. Each NFT imbues the properties of its wallet holder, and when sent to someone else, will transform.",
            "image://",
            Strings.toString(ROYALTY_BPS),
            "",
            "notablezorbs.xyz",
            payable(deployedDrop)
        );
        vm.prank(OWNER_ADDRESS);
        drop.setMetadataRenderer(renderer, "");
    }

    function setUp() public {
        setUp_Zora();
        setUp_Drop();
    }

    function test_Purchase() public {
        drop.purchase{value: 10 * 0.0069 ether}(10);
        assertEq(drop.totalSupply(), 10);
    }

    function test_ZorbRenderAddress() public {
        vm.prank(OWNER_ADDRESS);
        drop.adminMint(OWNER_ADDRESS, 1);

        address ownerOf = renderer.getZorbRenderAddress(1);
        assertEq(ownerOf, OWNER_ADDRESS);
    }

    function test_ZorbMetadata() public {
        vm.prank(OWNER_ADDRESS);
        drop.adminMint(OWNER_ADDRESS, 1);

        string memory uri = drop.tokenURI(1);
        assertEq(
            uri,
            "data:application/json;base64,eyJuYW1lIjogIk5vdGFibGUgWm9yYiAjMSIsICJ0aXRsZSI6ICJOb3RhYmxlIFpvcmIgIzEiLCAiZGVzY3JpcHRpb24iOiAiVGhpcyBab3JiIG1heSBvciBtYXkgbm90IGJlIG5vdGFibGUuIEVhY2ggTkZUIGltYnVlcyB0aGUgcHJvcGVydGllcyBvZiBpdHMgd2FsbGV0IGhvbGRlciwgYW5kIHdoZW4gc2VudCB0byBzb21lb25lIGVsc2UsIHdpbGwgdHJhbnNmb3JtLiIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSFpwWlhkQ2IzZzlJakFnTUNBeE1UQWdNVEV3SWo0OFpHVm1jejQ4Y21Ga2FXRnNSM0poWkdsbGJuUWdhV1E5SW1kNmNpSWdaM0poWkdsbGJuUlVjbUZ1YzJadmNtMDlJblJ5WVc1emJHRjBaU2cyTmk0ME5UYzRJREkwTGpNMU56VXBJSE5qWVd4bEtEYzFMakk1TURncElpQm5jbUZrYVdWdWRGVnVhWFJ6UFNKMWMyVnlVM0JoWTJWUGJsVnpaU0lnY2owaU1TSWdZM2c5SWpBaUlHTjVQU0l3SlNJK1BITjBiM0FnYjJabWMyVjBQU0l4TlM0Mk1pVWlJSE4wYjNBdFkyOXNiM0k5SW1oemJDZ3dMQ0EzTVNVc0lEZ3lKU2tpSUM4K1BITjBiM0FnYjJabWMyVjBQU0l6T1M0MU9DVWlJSE4wYjNBdFkyOXNiM0k5SW1oemJDZ3hMQ0EzTlNVc0lEWTFKU2tpSUM4K1BITjBiM0FnYjJabWMyVjBQU0kzTWk0NU1pVWlJSE4wYjNBdFkyOXNiM0k5SW1oemJDZzNMQ0E0TUNVc0lEUXlKU2tpSUM4K1BITjBiM0FnYjJabWMyVjBQU0k1TUM0Mk15VWlJSE4wYjNBdFkyOXNiM0k5SW1oemJDZzVMQ0E0TWlVc0lETXpKU2tpSUM4K1BITjBiM0FnYjJabWMyVjBQU0l4TURBbElpQnpkRzl3TFdOdmJHOXlQU0pvYzJ3b01UQXNJRGd5SlN3Z016SWxLU0lnTHo0OEwzSmhaR2xoYkVkeVlXUnBaVzUwUGp3dlpHVm1jejQ4WnlCMGNtRnVjMlp2Y20wOUluUnlZVzV6YkdGMFpTZzFMRFVwSWo0OGNHRjBhQ0JtYVd4c0xYSjFiR1U5SW1WMlpXNXZaR1FpSUdOc2FYQXRjblZzWlQwaVpYWmxibTlrWkNJZ1pEMGlUVFkyTGpnZ09TNDBNamt5TmtNMk5TNHdORFVnTmk0MU5EazBPU0EyTWk0MU56VWdOQzR4TmprM0lEVTVMall6TlNBeUxqVXhORGd6UXpVMkxqWTVJREF1T0RZME9UWXhJRFV6TGpNM05TQXdJRFV3SURCRE5ESXVPRGcxSURBZ016WXVOalVnTXk0M056UTJOeUF6TXk0eUlEa3VORE0wTWpKRE1qa3VPVElnT0M0Mk16a3lPQ0F5Tmk0ME9TQTRMalk1T1RNZ01qTXVNalFnT1M0Mk1Ea3lNME14T1M0NU9TQXhNQzQxTVRreUlERTNMakF6SURFeUxqSTFOQ0F4TkM0Mk5DQXhOQzQyTXpnNFF6RXlMakkxTlNBeE55NHdNamcySURFd0xqVXlJREU1TGprNE9EUWdPUzQyTURrNU9TQXlNeTR5TXpneFF6Z3VOams1T1RrZ01qWXVORGczT1NBNExqWXpPVGszSURJNUxqa3hOellnT1M0ME16UTVOeUF6TXk0eE9UYzBRell1TlRVME9UY2dNelF1T1RVeU1pQTBMakUyT1RrNUlETTNMalF5TWlBeUxqVXhPVGs1SURRd0xqTTJNVGhETUM0NE5qUTVPRGtnTkRNdU16QTJOaUF3SURRMkxqWXlNVE1nTUNBME9TNDVPVFpETUNBMU55NHhNVEExSURNdU56YzFNREVnTmpNdU16UWdPUzQwTXpBd01TQTJOaTQzT1RRM1F6Z3VOak0xTURFZ056QXVNRGMwTlNBNExqWTVOVEF6SURjekxqVXdORElnT1M0Mk1EVXdNeUEzTmk0M05UUkRNVEF1TlRFMUlEZ3dMakF3TXpjZ01USXVNalVnT0RJdU9UWXpOU0F4TkM0Mk16VWdPRFV1TXpVek0wTXhOeTR3TWpVZ09EY3VOek00TVNBeE9TNDVPRFVnT0RrdU5EY3lPU0F5TXk0eU16VWdPVEF1TXpneU9VTXlOaTQwT0RVZ09URXVNamt5T0NBeU9TNDVNVFVnT1RFdU16VXlPQ0F6TXk0eE9UVWdPVEF1TlRVM09VTXpOUzQyTXpVZ09UUXVOVFkzTmlBek9TNDBNalVnT1RjdU5UWTNNeUEwTXk0NE9EVWdPVGt1TURJM01rTTBPQzR6TkNBeE1EQXVORGd5SURVekxqRTNOU0F4TURBdU16QXlJRFUzTGpVeElEazRMalV3TnpKRE5qRXVNemNnT1RZdU9UQTNOQ0EyTkM0Mk1pQTVOQzR4TWpjMUlEWTJMamdnT1RBdU5UWXlPRU0zTUM0d09DQTVNUzR6TmpJNElEY3pMalV4SURreExqSTVOemdnTnpZdU56WWdPVEF1TXpnM09FTTRNQzR3TVRVZ09Ea3VORGMzT1NBNE1pNDVOelVnT0RjdU56UXpNU0E0TlM0ek5pQTROUzR6TlRneVF6ZzNMamMxSURneUxqazJPRFFnT0RrdU5EZ2dPREF1TURBNE55QTVNQzR6T1RVZ056WXVOelUwUXpreExqTXdOU0EzTXk0MU1EUXlJRGt4TGpNMk5TQTNNQzR3TnpRMUlEa3dMalUyTlNBMk5pNDNPVFEzUXprekxqUTBOU0EyTlM0d016azVJRGsxTGpneklEWXlMalUzTURFZ09UY3VORGdnTlRrdU5qTXdNME01T1M0eE16VWdOVFl1TmpnMU5TQXhNREFnTlRNdU16Y3dPQ0F4TURBZ05Ea3VPVGsyUXpFd01DQTBOaTQyTWpFeklEazVMakV6TlNBME15NHpNRFkySURrM0xqUTRJRFF3TGpNMk1UaERPVFV1T0RNZ016Y3VOREl5SURrekxqUTBOU0F6TkM0NU5USXlJRGt3TGpVMk5TQXpNeTR4T1RjMFF6a3hMak0ySURJNUxqa3hOellnT1RFdU15QXlOaTQwT0RjNUlEa3dMak01SURJekxqSXpPREZET0RrdU5EYzFJREU1TGprNE9EUWdPRGN1TnpRZ01UY3VNREk0TnlBNE5TNHpOVFVnTVRRdU5qUXpPRU00TWk0NU55QXhNaTR5TlRrZ09EQXVNREVnTVRBdU5USTBNaUEzTmk0M05pQTVMall3T1RJelF6Y3pMalV4TlNBNExqWTVORE1nTnpBdU1EZ2dPQzQyTXpRek15QTJOaTQ0SURrdU5ESTVNalphVFRRM0xqQXhJRFkzTGprNE9UWk1Oamt1T0RJZ016TXVOemN5TkVNM01pNDJOU0F5T1M0MU5ESTNJRFkyTGpBMk5TQXlOUzR4TlRNZ05qTXVNalFnTWprdU16Z3lOMHcwTXk0eE1TQTFPUzQxT1RVelRETTJMakkxTlNBMU1pNDNOVFU0UXpNeUxqWTNJRFE1TGpFME5qRWdNamN1TURjMUlEVTBMamN6TlRjZ016QXVOamMxSURVNExqTXpOVFJNTkRFdU5USTFJRFk1TGpBNE5EVkROREV1T1RVMUlEWTVMak0zTkRVZ05ESXVORFFnTmprdU5UYzBOU0EwTWk0NU5TQTJPUzQyTnprMVF6UXpMalEySURZNUxqYzNPVFVnTkRNdU9UZzFJRFk1TGpjM09UVWdORFF1TkRrMUlEWTVMalkzTkRWRE5EVXVNREExSURZNUxqVTNORFVnTkRVdU5Ea2dOamt1TXpjME5TQTBOUzQ1TWlBMk9TNHdOemsxUXpRMkxqTTFOU0EyT0M0M09EazJJRFEyTGpjeU5TQTJPQzQwTWpRMklEUTNMakF4SURZM0xqazRPVFphSWlCbWFXeHNQU0oxY213b0kyZDZjaWtpTHo0OGNHRjBhQ0JrUFNKTk5qWXVNemN6SURrdU5qa3dNVGxNTmpZdU5UWXpJREV3TGpBd01UbE1Oall1T1RFM09DQTVMamt4TlRrMFF6Y3dMakV4TkRjZ09TNHhOREV3T0NBM015NDBOakkwSURrdU1UazVOalVnTnpZdU5qSTBNeUF4TUM0d09URXlURGMyTGpZeU5EVWdNVEF1TURreE0wTTNPUzQzT1RJeElERXdMams0TXpFZ09ESXVOamMzSURFeUxqWTNOREVnT0RVdU1EQXhOQ0F4TkM0NU9UZzJRemczTGpNeU5Ua2dNVGN1TXpJeklEZzVMakF4TnlBeU1DNHlNRGM1SURnNUxqa3dPRGNnTWpNdU16YzFOVU01TUM0M09UVTFJREkyTGpVME1qZ2dPVEF1T0RVek9TQXlPUzQ0T0RVMklEa3dMakEzT1RFZ016TXVNRGd5TWt3NE9TNDVPVE14SURNekxqUXpOMHc1TUM0ek1EUTVJRE16TGpZeU4wTTVNeTR4TVRFM0lETTFMak16TnpRZ09UVXVORE0yTVNBek55NDNORFEzSURrM0xqQTBOQ0EwTUM0Mk1EazNURGszTGpBME5ERWdOREF1TmpBNU9VTTVPQzQyTlRjZ05ETXVORGdnT1RrdU5TQTBOaTQzTVRBMklEazVMalVnTlRCRE9Ua3VOU0ExTXk0eU9EazBJRGs0TGpZMU55QTFOaTQxTWpBeElEazNMakEwTkRFZ05Ua3VNemt3TVV3NU55NHdORFFnTlRrdU16a3dNME01TlM0ME16WXhJRFl5TGpJMU5UTWdPVE11TVRFeE55QTJOQzQyTmpJMklEa3dMak13TkRrZ05qWXVNemN6VERnNUxqazVNallnTmpZdU5UWXpNMHc1TUM0d056a3pJRFkyTGpreE9EVkRPVEF1T0RVNE9TQTNNQzR4TVRRM0lEa3dMamd3TURRZ056TXVORFUzTXlBNE9TNDVNVE0ySURjMkxqWXlORGRET0RrdU1ESXhOeUEzT1M0M09UYzFJRGczTGpNek5UY2dPREl1TmpneU15QTROUzR3TURZMUlEZzFMakF4TVRSRE9ESXVOamd5SURnM0xqTXpOVGtnTnprdU56azNNeUE0T1M0d01qWTNJRGMyTGpZeU5UUWdPRGt1T1RFek5FdzNOaTQyTWpVeUlEZzVMamt4TXpWRE56TXVORFUzTWlBNU1DNDRNREExSURjd0xqRXhORFFnT1RBdU9EWXpOeUEyTmk0NU1UZzFJRGt3TGpBNE5ESk1Oall1TlRZek9TQTRPUzQ1T1RjM1REWTJMak0zTXpRZ09UQXVNekE1TWtNMk5DNHlORGcySURrekxqYzROQ0EyTVM0d09EQTRJRGsyTGpRNU16WWdOVGN1TXpFNE5TQTVPQzR3TlRNeFF6VXpMakE1TkRJZ09Ua3VPREF5TXlBME9DNHpPREl4SURrNUxqazNOemdnTkRRdU1EUXdNaUE1T0M0MU5UazNRek01TGpZNU16UWdPVGN1TVRNMk55QXpOaUE1TkM0eU1UTWdNek11TmpJeU1pQTVNQzR6TURVeFRETXpMalF6TWpNZ09Ea3VPVGt6TVV3ek15NHdOemN6SURrd0xqQTNPVEZETWprdU9EZ3dOQ0E1TUM0NE5UUWdNall1TlRNM05DQTVNQzQzT1RVMElESXpMak0yT1RnZ09Ea3VPVEE0TlVNeU1DNHlNRE14SURnNUxqQXlNVGtnTVRjdU16RTROQ0E0Tnk0ek16RXpJREUwTGprNE9EZ2dPRFV1TURBMk4wTXhNaTQyTmpRZ09ESXVOamMzSURFd0xqazNNeklnTnprdU56a3lNU0F4TUM0d09EWTFJRGMyTGpZeU5USkRPUzR4T1RrMklEY3pMalExTnpjZ09TNHhOREV3T1NBM01DNHhNVFEySURrdU9URTFPVFFnTmpZdU9URTNPRXd4TUM0d01ERTRJRFkyTGpVMk16Uk1PUzQyT1RBMk9TQTJOaTR6TnpNelF6UXVNVGM0TVRNZ05qTXVNREExTkNBd0xqVWdOVFl1T1RNek5pQXdMalVnTlRCRE1DNDFJRFEyTGpjeE1EWWdNUzR6TkRNd01pQTBNeTQwT0NBeUxqazFOVGc0SURRd0xqWXdPVGxNTWk0NU5UWXdNU0EwTUM0Mk1EazNRelF1TlRZek9UTWdNemN1TnpRME55QTJMamc0T0RNZ016VXVNek0zTkNBNUxqWTVOVEUxSURNekxqWXlOMHd4TUM0d01EWTVJRE16TGpRek4wdzVMamt5TURrZ016TXVNRGd5TWtNNUxqRTBOakExSURJNUxqZzROVFFnT1M0eU1EUTFOaUF5Tmk0MU5ESXpJREV3TGpBNU1UVWdNak11TXpjME9FTXhNQzQ1TnpneUlESXdMakl3T0NBeE1pNDJOamc1SURFM0xqTXlNeklnTVRRdU9Ua3pOU0F4TkM0NU9UTTFRekUzTGpNeU16SWdNVEl1TmpZNE9TQXlNQzR5TURnZ01UQXVPVGM0TWlBeU15NHpOelE0SURFd0xqQTVNVFZETWpZdU5UUXlNeUE1TGpJd05EVTJJREk1TGpnNE5UUWdPUzR4TkRZd05TQXpNeTR3T0RJeUlEa3VPVEl3T1V3ek15NDBNemNnTVRBdU1EQTJPVXd6TXk0Mk1qWTVJRGt1TmprMU1rTXpOaTQ1T0RrNElEUXVNVGM0TVRrZ05ETXVNRFkyTWlBd0xqVWdOVEFnTUM0MVF6VXpMakk0T1RRZ01DNDFJRFUyTGpVeU1ETWdNUzR6TkRNd05pQTFPUzR6T1RBMklESXVPVFV4TWtNMk1pNHlOVFlnTkM0MU5qUTBNaUEyTkM0Mk5qTWdOaTQ0T0RNNU5TQTJOaTR6TnpNZ09TNDJPVEF4T1ZvaUlITjBjbTlyWlQwaWNtZGlZU2d3TERBc01Dd3dMakEzTlNraUlHWnBiR3c5SW5SeVlXNXpjR0Z5Wlc1MElpQnpkSEp2YTJVdGQybGtkR2c5SWpFaUx6NDhMMmMrUEM5emRtYysifQ=="
        );
    }

    function test_ZorbMetadataForBurn() public {
        bytes[5] memory colors = renderer.gradientForAddress(
            address(0x34eEBEE6942d8Def3c125458D1a86e0A897fd6f9)
        );
        console.log(string(abi.encodePacked(colors[0])));
        console.log(string(abi.encodePacked(colors[1])));
        console.log(string(abi.encodePacked(colors[2])));
        console.log(string(abi.encodePacked(colors[3])));
        console.log(string(abi.encodePacked(colors[4])));
    }
}

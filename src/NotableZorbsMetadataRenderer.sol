// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import {ColorLib} from 'zorb/ColorLib.sol';
import {Base64} from 'base64/base64.sol';
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {IMetadataRenderer} from "zora-drops-contracts/interfaces/IMetadataRenderer.sol";
import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";

contract NotableZorbsMetadataRenderer is IMetadataRenderer, Ownable {

    string public name;
    string public description;
    string public contractImage;
    string public sellerFeeBasisPoints;
    string public sellerFeeRecipient;
    string public externalLink;
    address public notableZorbAddress;

    constructor(
        string memory _name,
        string memory _description,
        string memory _contractImage,
        string memory _sellerFeeBasisPoints,
        string memory _sellerFeeRecipient,
        string memory _externalLink,
        address _notableZorbAddress,
        address _ownerAddress
    ) {
        notableZorbAddress = _notableZorbAddress;
        name = _name;
        description = _description;
        contractImage = _contractImage;
        sellerFeeBasisPoints = _sellerFeeBasisPoints;
        sellerFeeRecipient = _sellerFeeRecipient;
        externalLink = _externalLink;
        transferOwnership(_ownerAddress);
    }


    function gradientForAddress(address user) public pure returns (bytes[5] memory) {
        return ColorLib.gradientForAddress(user);
    }

    function zorbForAddress(address user) public view returns (string memory) {
        bytes[5] memory colors = gradientForAddress(user);
        string memory encoded = Base64.encode(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 110 110"><defs>'
                '<radialGradient id="gzr" gradientTransform="translate(66.4578 24.3575) scale(75.2908)" gradientUnits="userSpaceOnUse" r="1" cx="0" cy="0%">'
                '<stop offset="15.62%" stop-color="',
                colors[0],
                '" /><stop offset="39.58%" stop-color="',
                colors[1],
                '" /><stop offset="72.92%" stop-color="',
                colors[2],
                '" /><stop offset="90.63%" stop-color="',
                colors[3],
                '" /><stop offset="100%" stop-color="',
                colors[4],
                '" /></radialGradient></defs><g transform="translate(5,5)">'
                '<path fill-rule="evenodd" clip-rule="evenodd" d="M66.8 9.42926C65.045 6.54949 62.575 4.1697 59.635 2.51483C56.69 0.864961 53.375 0 50 0C42.885 0 36.65 3.77467 33.2 9.43422C29.92 8.63928 26.49 8.6993 23.24 9.60923C19.99 10.5192 17.03 12.254 14.64 14.6388C12.255 17.0286 10.52 19.9884 9.60999 23.2381C8.69999 26.4879 8.63997 29.9176 9.43497 33.1974C6.55497 34.9522 4.16999 37.422 2.51999 40.3618C0.864989 43.3066 0 46.6213 0 49.996C0 57.1105 3.77501 63.34 9.43001 66.7947C8.63501 70.0745 8.69503 73.5042 9.60503 76.754C10.515 80.0037 12.25 82.9635 14.635 85.3533C17.025 87.7381 19.985 89.4729 23.235 90.3829C26.485 91.2928 29.915 91.3528 33.195 90.5579C35.635 94.5676 39.425 97.5673 43.885 99.0272C48.34 100.482 53.175 100.302 57.51 98.5072C61.37 96.9074 64.62 94.1275 66.8 90.5628C70.08 91.3628 73.51 91.2978 76.76 90.3878C80.015 89.4779 82.975 87.7431 85.36 85.3582C87.75 82.9684 89.48 80.0087 90.395 76.754C91.305 73.5042 91.365 70.0745 90.565 66.7947C93.445 65.0399 95.83 62.5701 97.48 59.6303C99.135 56.6855 100 53.3708 100 49.996C100 46.6213 99.135 43.3066 97.48 40.3618C95.83 37.422 93.445 34.9522 90.565 33.1974C91.36 29.9176 91.3 26.4879 90.39 23.2381C89.475 19.9884 87.74 17.0287 85.355 14.6438C82.97 12.259 80.01 10.5242 76.76 9.60923C73.515 8.6943 70.08 8.63433 66.8 9.42926ZM47.01 67.9896L69.82 33.7724C72.65 29.5427 66.065 25.153 63.24 29.3827L43.11 59.5953L36.255 52.7558C32.67 49.1461 27.075 54.7357 30.675 58.3354L41.525 69.0845C41.955 69.3745 42.44 69.5745 42.95 69.6795C43.46 69.7795 43.985 69.7795 44.495 69.6745C45.005 69.5745 45.49 69.3745 45.92 69.0795C46.355 68.7896 46.725 68.4246 47.01 67.9896Z" fill="url(#gzr)"/>'
                '<path d="M66.373 9.69019L66.563 10.0019L66.9178 9.91594C70.1147 9.14108 73.4624 9.19965 76.6243 10.0912L76.6245 10.0913C79.7921 10.9831 82.677 12.6741 85.0014 14.9986C87.3259 17.323 89.017 20.2079 89.9087 23.3755C90.7955 26.5428 90.8539 29.8856 90.0791 33.0822L89.9931 33.437L90.3049 33.627C93.1117 35.3374 95.4361 37.7447 97.044 40.6097L97.0441 40.6099C98.657 43.48 99.5 46.7106 99.5 50C99.5 53.2894 98.657 56.5201 97.0441 59.3901L97.044 59.3903C95.4361 62.2553 93.1117 64.6626 90.3049 66.373L89.9926 66.5633L90.0793 66.9185C90.8589 70.1147 90.8004 73.4573 89.9136 76.6247C89.0217 79.7975 87.3357 82.6823 85.0065 85.0114C82.682 87.3359 79.7973 89.0267 76.6254 89.9134L76.6252 89.9135C73.4572 90.8005 70.1144 90.8637 66.9185 90.0842L66.5639 89.9977L66.3734 90.3092C64.2486 93.784 61.0808 96.4936 57.3185 98.0531C53.0942 99.8023 48.3821 99.9778 44.0402 98.5597C39.6934 97.1367 36 94.213 33.6222 90.3051L33.4323 89.9931L33.0773 90.0791C29.8804 90.854 26.5374 90.7954 23.3698 89.9085C20.2031 89.0219 17.3184 87.3313 14.9888 85.0067C12.664 82.677 10.9732 79.7921 10.0865 76.6252C9.1996 73.4577 9.14109 70.1146 9.91594 66.9178L10.0018 66.5634L9.69069 66.3733C4.17813 63.0054 0.5 56.9336 0.5 50C0.5 46.7106 1.34302 43.48 2.95588 40.6099L2.95601 40.6097C4.56393 37.7447 6.8883 35.3374 9.69515 33.627L10.0069 33.437L9.9209 33.0822C9.14605 29.8854 9.20456 26.5423 10.0915 23.3748C10.9782 20.208 12.6689 17.3232 14.9935 14.9935C17.3232 12.6689 20.208 10.9782 23.3748 10.0915C26.5423 9.20456 29.8854 9.14605 33.0822 9.9209L33.437 10.0069L33.6269 9.6952C36.9898 4.17819 43.0662 0.5 50 0.5C53.2894 0.5 56.5203 1.34306 59.3906 2.9512C62.256 4.56442 64.663 6.88395 66.373 9.69019Z" stroke="rgba(0,0,0,0.075)" fill="transparent" stroke-width="1"/>'
                "</g></svg>"
            )
        );
        return string(abi.encodePacked("data:image/svg+xml;base64,", encoded));
    }

    function getZorbRenderAddress(uint256 tokenId) public view returns (address){
        return ERC721Drop(notableZorbAddress).ownerOf(tokenId);
    }

    function tokenURI(uint256 tokenId) external view returns (string memory){
        string memory json;

        string memory idString = Strings.toString(tokenId);
        address ownerOfZorb = getZorbRenderAddress(tokenId);

        json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        's #',
                        idString,
                        '", "title": "',
                        name,
                        's #',
                        idString,
                        '", "description": "',
                        description,
                        '", "image": "',
                        zorbForAddress(ownerOfZorb),
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function contractURI() public view returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "',
                                name,
                                '", "description": "',
                                description,
                                '", "image": "',
                                contractImage,
                                '", "seller_fee_basis_points": "',
                                sellerFeeBasisPoints,
                                '", "seller_fee_recipient": "',
                                sellerFeeRecipient,
                                '", "external_link": "',
                                externalLink,
                                '"}'
                            )
                        )
                    )
                )
            )
        );
    }

    function initializeWithData(bytes memory initData) external {
        // do nothing
    }
}

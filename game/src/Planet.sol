// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Planet is ERC721 {
    constructor() ERC721("Planet", "PLANET") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://galacticwar.com/";
    }
}

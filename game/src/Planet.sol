// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Planet is ERC721 {
    // Mapping from token ID to ...
    mapping(uint256 => uint) private _num_shields;
    mapping(uint256 => uint) private _uranium_rate;
    mapping(uint256 => uint) private _uranium_end_block;
    mapping(uint256 => uint) private _uranium_last_payout_block;


    constructor() ERC721("Planet", "PLNT") {}

    // function _baseURI() internal pure override returns (string memory) {
    //     return "https://galacticwar.com/";
    // }

    function mine(uint256 tokenId) public {
        uint mine_until_block = min(_uranium_end_block[tokenId], block.number);
        uint blocks_to_mine_uranium_for = mine_until_block - _uranium_last_payout_block[tokenId];
        // require(blocks_to_mine_uranium_for > 0, "Cannot mine for zero blocks");

        uint uranium_mined = _uranium_rate[tokenId] * blocks_to_mine_uranium_for;
        // require(uranium_mined > 0, "Cannot mine zero Uranium");

        _uranium_last_payout_block[tokenId] = block.number;

        Uranium._mint(_owner[tokenId], uranium_mined);
    }

    function attack(uint256 tokenId) public {
        // ...
    }
}

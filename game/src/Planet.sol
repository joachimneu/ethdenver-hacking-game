// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

import "../src/Uranium.sol";
import "../src/Spaceship.sol";


contract Planet is ERC721 {
    // dependencies on other contracts
    Uranium _Uranium;
    Spaceship _Spaceship;
    uint256 COST_DISCOVERY_EXPEDITION;

    // Mapping from token ID to ...
    mapping(uint256 => bool) private _discovered;
    mapping(uint256 => uint) private _discovery_end_block;
    mapping(uint256 => uint) private _num_shields;
    mapping(uint256 => uint) private _uranium_rate;
    mapping(uint256 => uint) private _uranium_end_block;
    mapping(uint256 => uint) private _uranium_last_payout_block;


    constructor(Uranium uran, Spaceship ship, uint256 cost_discovery_expedition) ERC721("Planet", "PLNT") {
        _Uranium = uran;
        _Spaceship = ship;
        COST_DISCOVERY_EXPEDITION = cost_discovery_expedition;
    }

    function mine(uint256 tokenId) public {
        require(_discovered[tokenId], "Planet needs to be discovered");

        uint mine_until_block = Math.min(_uranium_end_block[tokenId], block.number);
        uint blocks_to_mine_uranium_for = mine_until_block - _uranium_last_payout_block[tokenId];
        // require(blocks_to_mine_uranium_for > 0, "Cannot mine for zero blocks");

        uint uranium_mined = _uranium_rate[tokenId] * blocks_to_mine_uranium_for;
        // require(uranium_mined > 0, "Cannot mine zero Uranium");

        _uranium_last_payout_block[tokenId] = block.number;

        _Uranium.mine(ownerOf(tokenId), uranium_mined);
    }

    // function attack(uint256 tokenId) public {
    //     // ...
    // }

    function discoveryBegin() public payable {

    }

    function discoveryFinalize(uint256 tokenId) public {
        require(!_discovered[tokenId], "Planet needs to not be discovered");
        _discovered[tokenId] = true;

        require(_discovery_end_block[tokenId] > 0, "Discovery expedition not begun");
        require(_discovery_end_block[tokenId] <= block.number, "Discovery expedition not completed");

    }
}

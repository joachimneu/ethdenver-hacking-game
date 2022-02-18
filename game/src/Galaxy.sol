// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import "../src/Uranium.sol";
import "../src/Spaceship.sol";


struct Planet {
    bool charted;
    uint discovery_end_block;

    uint num_shields;

    uint uranium_rate;
    uint uranium_end_block;
    uint uranium_last_payout_block;
}


contract Galaxy is ERC721, Ownable {
    // dependencies on other contracts
    Uranium _Uranium;
    Spaceship _Spaceship;
    uint256 COST_DISCOVERY_EXPEDITION;
    uint256 NEXT_TOKEN_ID;

    // Mapping from token ID to ...
    mapping(uint256 => Planet) private _planets;

    constructor(address uran, address ship, uint256 cost_discovery_expedition) ERC721("Planet", "PLNT") {
        _Uranium = Uranium(uran);
        _Spaceship = Spaceship(ship);
        COST_DISCOVERY_EXPEDITION = cost_discovery_expedition;
        NEXT_TOKEN_ID = 1;
    }

    function withdrawDiscoveryExpeditionCosts() public onlyOwner {
        msg.sender.call.value(address(this).balance)();
    }

    function attack(uint256 tokenId, uint256 spaceships, uint256 initialInvestment) public {
        uint256 defenses = _num_shields[tokenId];
        uint256 subtract_amount = Math.min(defenses, spaceships);
        bool resultShip = _Spaceships.tryBurn(msg.sender, subtract_amount);
        assert(resultShip);
	bool resultUr = _Uranium.tryBurn(msg.sender, initialInvestment);
	assert(resultUr);

        planets[tokenId].num_shields = planets[tokenId].num_shields - subtract_amount + initialInvestment;

        if (spaceships > defenses) {
            transferFrom(ownerOf(tokenId), msg.sender, tokenId);
        }
    }

    function mine(uint256 tokenId) public {
        require(_exists(tokenId), "Planet non-existent");
        require(_planets[tokenId].charted, "Planet non-charted");

        uint mine_until_block = Math.min(_planets[tokenId].uranium_end_block, block.number);
        uint blocks_to_mine_uranium_for = mine_until_block - _planets[tokenId].uranium_last_payout_block;

        uint uranium_mined = _planets[tokenId].uranium_rate * blocks_to_mine_uranium_for;

        _planets[tokenId].uranium_last_payout_block = block.number;

        _Uranium.mine(ownerOf(tokenId), uranium_mined);
    }

    function discoveryBegin() public payable returns (uint256) {
        require(msg.value >= COST_DISCOVERY_EXPEDITION, "Expedition more expensive!");

        uint256 tokenId = NEXT_TOKEN_ID;
        NEXT_TOKEN_ID += 1;

        _mint(msg.sender, tokenId);
        _planets[tokenId].charted = false;
        _planets[tokenId].discovery_end_block = block.number + 3;

        return tokenId;
    }

    function discoveryFinalize(uint256 tokenId) public {
        require(_exists(tokenId), "Planet non-existent");
        require(!_planets[tokenId].charted, "Planet charted");
        require(_planets[tokenId].discovery_end_block < block.number, "Discovery not completed");

        _planets[tokenId].charted = true;
        _planets[tokenId].uranium_last_payout_block = block.number;

        bytes32 blkhash = blockhash(_planets[tokenId].discovery_end_block);
        uint8 randomness1 = uint8(blkhash[31]);
        uint8 randomness2 = uint8(blkhash[30]);

        if (randomness1 % 4 == 0) {
            _planets[tokenId].uranium_rate = 50;
        } else if (randomness1 % 4 == 1) {
            _planets[tokenId].uranium_rate = 30;
        } else if (randomness1 % 4 == 2) {
            _planets[tokenId].uranium_rate = 20;
        } else if (randomness1 % 4 == 3) {
            _planets[tokenId].uranium_rate = 10;
        }

        if (randomness2 % 4 == 0) {
            _planets[tokenId].uranium_end_block = 50;
        } else if (randomness2 % 4 == 1) {
            _planets[tokenId].uranium_end_block = 30;
        } else if (randomness2 % 4 == 2) {
            _planets[tokenId].uranium_end_block = 20;
        } else if (randomness2 % 4 == 3) {
            _planets[tokenId].uranium_end_block = 10;
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import "./Resource.sol";

struct Planet {
    bool charted;
    uint discovery_end_block;

    uint num_shields;

    uint uranium_rate;
    uint uranium_end_block;
    uint uranium_last_payout_block;
}


contract Galaxy is ERC721, Ownable {
    uint256 public constant DISCOVERY_COST = 1 ether;
    uint public constant DISCOVERY_DURATION = 3;
    uint public constant DISCOVERY_MAX_TOKENID = 10000;
    uint public constant SPACESHIP_POWER = 1;
    uint public constant SPACESHIP_COST = 1;
    uint public constant SHIELD_POWER = 1;
    uint public constant SHIELD_COST = 1;

    // dependencies on other contracts
    Resource _Uranium;
    Resource _Spaceship;

    // discovery of planets
    uint256 _next_token_id;

    // Mapping from token ID to ...
    mapping(uint256 => Planet) private _planets;

    constructor(address uran, address ship) ERC721("Planet", "PLNT") {
        _Uranium = Resource(uran);
        _Spaceship = Resource(ship);
        _next_token_id = 1;
    }

    function withdrawDiscoveryExpeditionCosts() public onlyOwner {
        msg.sender.call{value: address(this).balance}("");
    }

    function attack(uint256 tokenId, uint256 spaceships, uint256 initialInvestment) public {
        uint256 defenses = _planets[tokenId].num_shields;
        uint256 subtract_amount = Math.min(defenses, spaceships);

        _Spaceship.burn(msg.sender, subtract_amount);
        _Uranium.burn(msg.sender, initialInvestment);
        // bool resultShip = _Spaceship.tryBurn(msg.sender, subtract_amount);
        // require(resultShip, "Not enough ships");

        // bool resultUr = _Uranium.tryBurn(msg.sender, initialInvestment);
        // require(resultUr, "Not enough uranium");

        _planets[tokenId].num_shields = _planets[tokenId].num_shields - subtract_amount + initialInvestment;

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
        require(msg.value >= DISCOVERY_COST, "Expedition more expensive!");
        require(_next_token_id <= DISCOVERY_MAX_TOKENID, "All planets in this Galaxy discovered!");

        uint256 tokenId = _next_token_id;
        _next_token_id += 1;

        _mint(msg.sender, tokenId);
        _planets[tokenId].charted = false;
        _planets[tokenId].discovery_end_block = block.number + 1;

        return tokenId;
    }

    function discoveryFinalize(uint256 tokenId) public {
        require(_exists(tokenId), "Planet non-existent");
        require(!_planets[tokenId].charted, "Planet charted");
        require(_planets[tokenId].discovery_end_block + 3 <= block.number, "Discovery not completed");

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
            _planets[tokenId].uranium_end_block = 7200*5;
        } else if (randomness2 % 4 == 1) {
            _planets[tokenId].uranium_end_block = 7200*3;
        } else if (randomness2 % 4 == 2) {
            _planets[tokenId].uranium_end_block = 7200*2;
        } else if (randomness2 % 4 == 3) {
            _planets[tokenId].uranium_end_block = 7200*1;
        }
    }

    function buildSpaceships(uint256 spaceships) public {
        uint256 cost = spaceships * SPACESHIP_COST;

        // bool burn_success = _Uranium.tryBurn(msg.sender, cost);
        // require(burn_success, "Not enough uranium");
        _Uranium.burn(msg.sender, cost);
        _Spaceship.mine(msg.sender, spaceships);
    }

    function buildShields(uint256 tokenId, uint256 shields) public {
        require(_exists(tokenId), "Planet non-existent");
        require(_planets[tokenId].charted, "Planet non-charted");

        uint256 cost = shields * SHIELD_COST;

        // bool burn_success = _Uranium.tryBurn(msg.sender, cost);
        // require(burn_success, "Not enough uranium");
        _Uranium.burn(msg.sender, cost);
        _planets[tokenId].num_shields += shields;
    }
}

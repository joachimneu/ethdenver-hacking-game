// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Resource.sol";
import "../Galaxy.sol";

interface CheatCodes {
    function roll(uint256) external;
}

contract ContractTest is DSTest {
    Galaxy g;
    Resource u;
    Resource s;
    uint256 tokenId;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        u = new Resource("Uranium", "U");
        s = new Resource("Spaceship", "S");
        g = new Galaxy(address(u), address(s));
        u.setupGalaxy(address(g));
        s.setupGalaxy(address(g));
        cheats.roll(10);
        tokenId = g.discoveryBegin();
        cheats.roll(20);
        g.discoveryFinalize(tokenId);
    }
}

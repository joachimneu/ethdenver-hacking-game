// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";

import "../Resource.sol";
import "../Galaxy.sol";

interface CheatCodes {
    function roll(uint256) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address who, uint256 newBalance) external;
}

contract ContractTest is DSTest {
    Galaxy g;
    Resource u;
    Resource s;
    uint256 testTokenId;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    receive() external payable {}

    fallback() external payable {}

    function setUp() public {
        u = new Resource("Uranium", "U");
        s = new Resource("Spaceship", "S");
        g = new Galaxy(address(u), address(s));
        u.setupGalaxy(address(g));
        s.setupGalaxy(address(g));
        cheats.roll(10);
        cheats.deal(address(0x567), 1 ether);
        cheats.startPrank(address(0x567));
        testTokenId = g.discoveryBegin{value: 1 ether}();
        cheats.roll(20);
        g.discoveryFinalize(testTokenId);
        cheats.stopPrank();
    }

    function testMine() public {
        cheats.roll(20);
        g.mine(testTokenId);
        assert(u.balanceOf(g.ownerOf(testTokenId))==0);
        cheats.roll(21);
        g.mine(testTokenId);
        assert(u.balanceOf(g.ownerOf(testTokenId))>=10);
        cheats.roll(23);
        g.mine(testTokenId);
        assert(u.balanceOf(g.ownerOf(testTokenId))>=30);
        // there seems to be no cheatcode in forge to set
        // block hash
    }

    function testWithdraw() public {
        assert(address(g).balance == 1 ether);
        uint256 initbal = address(this).balance;
        g.withdrawDiscoveryExpeditionCosts();
        assert(address(g).balance == 0 ether);
        assert(address(this).balance == initbal + 1 ether);
    }

    function testFailUnauthorizedWithdraw() public {
        cheats.startPrank(address(0x123));
        g.withdrawDiscoveryExpeditionCosts();
    }

    function testBuildSpaceships() public {
        // act as the galaxy to send us some uranium
        cheats.startPrank(address(g));
        u.mint(address(0x567), 10000);
        cheats.startPrank(address(0x567));
        g.buildSpaceships(5);
        assert(s.balanceOf(address(0x567))==5);
    }

    function testBuildShields() public {
        // act as the galaxy to send us some uranium
        cheats.startPrank(address(g));
        u.mint(address(0x567), 10000);
        cheats.startPrank(address(0x567));
        g.buildShields(testTokenId, 5);
        assert(g.getNumShields(testTokenId)==5);
    }
}

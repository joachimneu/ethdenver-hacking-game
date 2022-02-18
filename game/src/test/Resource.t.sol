// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../Resource.sol";

interface CheatCodes {
  function prank(address) external;
  function startPrank(address) external;
}

contract ResourceTest {
    Resource u;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        u = new Resource("123", "456");
    }

    function testSetPlanet() public {
        address p = address(0x123);
        u.setup(p);
    }

    function testFailNonOwnerSetPlanet() public {
        cheats.prank(address(0x123));
        address p = address(0x123);
        u.setup(p);
    }

    function testPlanetMineBurn() public {
        u.setup(address(0x123));
        cheats.startPrank(address(0x123));

        u.mine(address(0x456), 100);
        assert(u.balanceOf(address(0x456)) == 100);

        bool res = u.tryBurn(address(0x456), 1000);
        assert(res == false);
        assert(u.balanceOf(address(0x456)) == 100);

        res = u.tryBurn(address(0x456), 5);
        assert(res == true);
        assert(u.balanceOf(address(0x456)) == 95);
    }

    function testFailUnauthorizedMine() public {
        u.setup(address(0x123));
        cheats.startPrank(address(0x124));

        u.mine(address(0x456), 100);
    }

    function testFailUnauthorizedBurn() public {
        u.setup(address(0x123));
        cheats.startPrank(address(0x124));

        u.tryBurn(address(0x456), 100);
    }
}

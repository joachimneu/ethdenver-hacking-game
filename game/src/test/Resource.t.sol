// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";

import "../Resource.sol";

interface CheatCodes {
  function prank(address) external;
  function startPrank(address) external;
}

contract ResourceTest is DSTest {
    Resource u;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        u = new Resource("123", "456");
    }

    function testSetGalaxy() public {
        address p = address(0x123);
        u.setupGalaxy(p);
    }

    function testFailNonOwnerSetGalaxy() public {
        cheats.prank(address(0x123));
        address p = address(0x123);
        u.setupGalaxy(p);
    }

    function testGalaxyMineAuthorizedBurn() public {
        u.setupGalaxy(address(0x123));
        cheats.startPrank(address(0x123));

        u.mine(address(0x456), 100);
        assertEq(u.balanceOf(address(0x456)), 100);

        u.burn(address(0x456), 5);
        assertEq(u.balanceOf(address(0x456)), 95);
    }

    function testFailGalaxyMineUnauthorizedBurn() public {
        u.setupGalaxy(address(0x123));
        cheats.startPrank(address(0x123));

        u.mine(address(0x456), 100);
        assertEq(u.balanceOf(address(0x456)), 100);

        u.burn(address(0x456), 1000);
    }

    function testFailUnauthorizedMine() public {
        u.setupGalaxy(address(0x123));
        cheats.startPrank(address(0x124));

        u.mine(address(0x456), 100);
    }

    function testFailUnauthorizedBurn() public {
        u.setupGalaxy(address(0x123));
        cheats.startPrank(address(0x124));

        u.burn(address(0x456), 100);
    }
}

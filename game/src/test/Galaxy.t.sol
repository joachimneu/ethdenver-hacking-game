// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";

import "../Resource.sol";
import "../Galaxy.sol";

contract ContractTest is DSTest {
    Galaxy g;
    Resource u;
    Resource s;

    function setUp() public {
        u = new Resource("Uranium", "U");
        s = new Resource("Spaceship", "S");
        g = new Galaxy(address(u), address(s));
    }
}

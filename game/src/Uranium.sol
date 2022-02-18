// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Uranium is ERC20, Ownable {
    address planet;
    
    constructor() ERC20("Uranium", "URAN") {
    }

    function setup(address planetAddr) public onlyOwner {
        planet = planetAddr;
    }

    function mine(address recipient, uint256 amount) public {
        require(msg.sender == planet, "Request not from this Galaxy");

        _mint(recipient, amount);
    }

    function tryBurn(address account, uint256 amount) public returns (bool ok) {
        require(msg.sender == planet, "Request not from this Galaxy");
        
        if (balanceOf(account) >= amount) {
            _burn(account, amount);
            return true;
        } else {
            return false;
        }
    }
}

interface CheatCodes {
  function prank(address) external;
  function startPrank(address) external;
}

contract UraniumTest {
    Uranium u;

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        u = new Uranium();
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

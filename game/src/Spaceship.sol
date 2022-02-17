// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Spaceship is ERC20, Ownable {
    address planet;
    constructor() ERC20("Spaceship", "SHIP") {
    }

    function setup(address planetAddr) public onlyOwner {
        planet = planetAddr;
    }

    function mine(address recipient, uint256 amount) public {
        assert(msg.sender == planet);
        _mint(recipient, amount);
    }

    function tryBurn(address account, uint256 amount) public returns (bool ok) {
        assert(msg.sender == planet);
        if (balanceOf(account) >= amount) {
            _burn(account, amount);
            return true;
        } else {
            return false;
        }
    }
}

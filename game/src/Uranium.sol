// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Uranium is ERC20, Ownable {
    address planet;
    constructor() ERC20("Uranium", "URAN") {
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

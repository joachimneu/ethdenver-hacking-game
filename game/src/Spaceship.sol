// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract Spaceship is ERC20, ERC20Burnable {
    constructor() ERC20("Spaceship", "SHIP") {
        
    }
}

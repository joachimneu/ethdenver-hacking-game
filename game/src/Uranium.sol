// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Uranium is ERC20, ERC20Burnable {
    constructor() ERC20("Uranium", "URAN") {
        
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Resource is ERC20, Ownable {
    address galaxy;
    
    constructor(string memory name, string memory ticker) ERC20(name, ticker) {
    }

    function setupGalaxy(address galaxyAddr) public onlyOwner {
        galaxy = galaxyAddr;
    }

    modifier onlyGalaxy() {
        require(msg.sender == galaxy, "Request not from this galaxy");
        _;
    }

    function mine(address recipient, uint256 amount) public onlyGalaxy {
        _mint(recipient, amount);
    }

    function burn(address account, uint256 amount) public onlyGalaxy {
        // require(balanceOf(account) >= amount, "Insufficient resource"); // <--- already done by OpenZeppelin library
        _burn(account, amount);
    }
}

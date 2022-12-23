// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract spnToken is ERC20{
error NotAdmin();
address private admin;
    constructor(uint _amount) ERC20("GameDao", "SPN"){
        _mint(_msgSender(),_amount* 10**18);
        admin =msg.sender;
    }



    function mintTokens(uint amount) external {
       if(msg.sender!=admin) revert NotAdmin();
        _mint(_msgSender(),amount);
    }

}
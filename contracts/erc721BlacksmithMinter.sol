//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-v0.7/access/Ownable.sol";
import "./multisig.sol";

contract erc721BlacksmithMinter is ERC721,Ownable {
    address private admin;
    multisig private dao;

    struct WeaponType {
        bytes32 weaponType;
        
    }
    
    constructor(address _DAO) ERC721("Weapons", "WPN") {
        dao  =multisig(_DAO);
        admin = multisig.admin();
    }

    modifier onlyAdmin {
        if(msg.sender!=admin) revert NotAdmin();
        _;
    }
}

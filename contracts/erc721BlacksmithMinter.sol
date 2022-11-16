//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-v0.7/access/Ownable.sol";
import "./multisig.sol";
import "./RNG.sol";

contract erc721BlacksmithMinter is ERC721,Ownable {
    address private admin;
    address private multisigAddress;
    multisig private dao;
    uint private wTypeCounter;
    uint tokenCounter;

    struct WeaponType {
      
       bytes32[] typeWeapon; //axe, sword, gun, etc
       bytes32[] weaponImage;
        
    }
    struct MintedWeapon{
     bytes32 weaponType;
     bytes32 imageUri;
    }
    mapping (uint => WeaponType) weaponType; 
    mapping (uint => MintedWeapon) mintedDetails;
    constructor(address _DAO) ERC721("Weapons", "WPN") RNG(subscriptionId, vrfCoordinator, keyHash){
        dao  =multisig(_DAO);
        multisigAddress = _DAO;
        admin = multisig.admin();
        wTypeCounter=0;
        tokenCounter = 0;
    }

 

    function addWeapon(uint id, address _address,bytes32 calldata _weapon, bytes32 calldata _imgUri) external payable
{
    if(msg.sender!=multisigAddress) revert NotAuthorized();
    if(!dao.gameApproved(_address)) revert GameNotFound();
    

    WeaponType storage weapon = weaponType[id];
    newWeapon.weapon.push(_weapon);
    newWeapon.weaponImage(_imgUri);

}

    function mintWeapon(uint id) external  {
        uint tokenID = ++tokenCounter;    
        _safeMint(_msgSender(),tokenID)    
        uint requestID = randomWords(1,200000);
    
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual
        override{
        //Retrieve details for mint using request ID
        WeaponType storage weapon = WeaponType[requestID];
        uint index = randomWords[0]%weapon.typeWeapon.length;

        MintDetails storage tokens =mintedDetails[tokenCounter];
        tokens.weaponType = weapon.typeWeapon[index];
        tokens.imageUri = weapon.weaponImage[index]; 

        

}

    function removeWeapon(uint id,bytes32 calldata _weaponType)  {
        
    }


}
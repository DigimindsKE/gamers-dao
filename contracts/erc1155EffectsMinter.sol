// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./multisig.sol";
import "./RNG.sol";

contract erc1155EffectsMinter is  ERC1155,RNG{
   error ZeroAddress();
   error NotApprovedCurrency();
   error InsufficientAmount();


    struct WeaponEffects {
        string[] effectName;
        string [] effectImage;
    }
    struct EffectStats {
        uint dmg;
        bool criticalChance;
        uint criticalDamage;

    }
    
    multisig dao;
    ICurrency token;
    uint private currencyID;
    uint private effectPrice;
    constructor(address _DAO) ERC1155(" ") RNG(subscriptionId, vrfCoordinator, keyHash) {
        if(_DAO== address(0)) revert ZeroAddress();
        dao = multisig(_DAO);
    }

    function setEffectPrice(uint _currencyID, uint _amount) external {
        if(!dao.currencyApproved(_currencyID)) revert NotApprovedCurrency();
        currencyID = _currencyID;
        effectPrice = _amount;

    }

    function addEffect(string memory effectName) external {
        
    }

    function mintEffect() external {
         if (token.balanceOf(_msgSender(), currencyID) <= effectPrice)
            revert InsufficientAmount();

        
    }

    function removeEffect() external{
        
    }


}
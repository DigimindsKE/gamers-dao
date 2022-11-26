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
   error NotAuthorized();
      error NotApprovedOperator();


    struct WeaponEffects {
        string[] effectName;
        string [] effectImage;
    }
    struct EffectStats {
        string effectNme;
        string effectImg;
        uint dmg;        
        uint criticalDamage;
        bool criticalChance;
    }
    mapping (uint => WeaponEffects) private weaponEffects;
    mapping (uint => EffectStats) private effectStats;
    
    //multisig private dao;
    ICurrency private token;
    
    uint private tokenCounter;
    uint private buyingCurrency;
    uint private buyingPrice;
  
    address private DAO;
    
    constructor(address _DAO, uint64 subscriptionId, address vrfCoordinator, bytes32 keyHash) ERC1155(" ") RNG(subscriptionId, vrfCoordinator, keyHash) {
        if(_DAO== address(0)) revert ZeroAddress();
       // dao = multisig(_DAO);
        DAO = _DAO;
    }

    function setEffectPrice(uint _currencyID, uint _amount) external {
        if (msg.sender!= DAO) revert NotAuthorized();
        if(_currencyID==0 || _amount ==0) revert InvalidInput();
        //if(!dao.currencyApproved(_currencyID)) revert NotApprovedCurrency();
        buyingCurrency = _currencyID;
        buyingPrice = _amount;

    }

    function addEffect(uint _id, string memory effectName, string memory url) external {
        if (msg.sender!= DAO) revert NotAuthorized();
        WeaponEffects storage effects = weaponEffects[_id];
        effects.effectName.push(effectName);
        effects.effectImage.push(url);

    }

   function mintWeapon(uint amount) external {
        //check if there is enough tokens in sender wallet
        if (token.balanceOf(_msgSender(), buyingCurrency) <= buyingPrice)
            revert InsufficientAmount();
        if (!token.isApproved(_msgSender(), address(this)))
            revert NotApprovedOperator();
        
        uint totalPrice = amount*buyingPrice;
        //send buying price to burn address
        token._burn(_msgSender(),buyingCurrency, totalPrice);
        uint tokenID = ++tokenCounter;
         _mint(_msgSender(), tokenID, amount ,"");
        uint requestId = requestRandomWords(1, 200000);

    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual
        override
    {
        uint tokencounter = tokenCounter;
        //Retrieve details for mint using request ID
        WeaponEffects memory effects = weaponEffects[tokencounter];
        uint index = randomWords[0] % effects.effectName.length;

        EffectStats storage tokens = effectStats[tokencounter];
        tokens.effectNme = effects.effectName[index];
        tokens.effectImg = effects.effectImage[index];       

    }

    function removeWeapon(uint id, string memory _WeaponEffects) external {
        if (msg.sender != DAO) revert NotAuthorized();
        WeaponEffects storage item = weaponEffects[id];

        string[] memory toBeDeleted = item.effectName;

        for (uint i = 0; i < toBeDeleted.length; ) {
            if (
                keccak256(abi.encodePacked(_WeaponEffects)) ==
                keccak256(abi.encodePacked(toBeDeleted[i]))
            ) {
                item.effectName[i] = item.effectName[item.effectName.length -1];
                item.effectName.pop();
                item.effectImage[i] = item.effectImage[item.effectImage.length - 1];
                item.effectImage.pop();
            }
            unchecked {
                i++;
            }
        }
    } 

}
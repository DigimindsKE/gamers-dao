// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./multisig.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Character is ERC721, Ownable {
    error ZeroAddress();
    error NotAuthorized();
    error NotEnoughXP();
    error MaxLevel();
    uint private counter;
    //default values set already to avoid characters minted with 0 stats
    uint private _basePower = 50;
    uint private _maxLvl = 50;
    uint private _maxXp =50;
    address private gameContract;
    address private DAO;
    struct CharStats {
        uint basePower;
        uint xp;
        uint maxLevel;
        uint maxXp;
        uint level;
    }

    mapping(uint => CharStats) public characterStats;

    multisig  public signer;     

    constructor( address _DAO) ERC721("Character", "Char") {
        if ( _DAO == address(0)) revert ZeroAddress();
        counter = 0;
        DAO = _DAO;
        signer = multisig(_DAO);
    }

    modifier onlyApproved {
        if (!signer.gameApproved(msg.sender)) revert NotAuthorized();
        _;
    }
    function safeMint() external {
        
        
        uint tokenID = ++counter;
        _safeMint(_msgSender(), counter);
        CharStats storage stats = characterStats[tokenID];
        stats.basePower = _basePower;
        stats.maxLevel = _maxLvl;
        stats.maxXp = _maxXp;
        stats.xp = 0;
        stats.level = 1;
    }

    function setBaseStats(
        uint _bpower,
        uint _mlvl,
        uint _mXp
    ) external  onlyApproved{
     
        _basePower = _bpower;
        _maxLvl = _mlvl;
        _maxXp = _mXp;
    }

    function upgradeCharacter(uint id) external {
   
        CharStats storage stats = characterStats[id];
       if (stats.xp != stats.maxXp) revert NotEnoughXP();
        if (stats.level >= stats.maxLevel) revert MaxLevel();
        uint level = ++stats.level;
        stats.xp = 0;
        //10% more XP required to reach max for new level
        uint XPMultiplier = ((11) ^ level) / (10 ^ level);
        uint maximum = stats.maxXp + XPMultiplier;
        stats.maxXp = maximum;
    }

    function getCharacterPower(uint id) external view returns (uint) {
        CharStats storage stats = characterStats[id];
              //5% more power per level
        uint XPMultiplier =((21) ^ stats.level) / (20 ^ stats.level);
     
        uint totalPower = stats.basePower * XPMultiplier;
         return totalPower;
    }
}

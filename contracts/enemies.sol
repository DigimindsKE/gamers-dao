// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract enemies {
    error NotAuthorised();
    //values tbd, lets go with 100 for now
    uint public multiplier;
    uint id;
    address private DAO;
    address private game;
    struct EnemyDetails {
        uint maxLevel;
        uint basePower;
        uint levelMultiplier;
        uint rewardId;
    }

    mapping(uint=>EnemyDetails)  public newEnemy;

    constructor(uint _multiplier,address _DAO, address _game) {
        multiplier = _multiplier;
        DAO=_DAO;
        game=_game;
        id = 0;
    }


      function generateEnemy(uint maxLevel, uint basePower, uint levelMultiplier) external {
        if(msg.sender!=DAO) revert NotAuthorised();
        uint enemyId = ++id;
        EnemyDetails storage details =newEnemy[enemyId];
        details.maxLevel = maxLevel;
        details.basePower = basePower;
        details.levelMultiplier = levelMultiplier; 
        details.rewardId = enemyId;
 

        //details.weaponPower = weapon;                                  
        //details.totalPower = weapon+power;
    }
 /*   function getStats(uint enemyID, uint level) external view returns(uint ){
      EnemyDetails storage details =newEnemy[enemyID];
      uint basePower = details.basePower;
      uint lvlMultiplier = details.levelMultiplier;
      uint totalPower =basePower*lvlMultiplier;

      return totalPower; 
    }*/

}
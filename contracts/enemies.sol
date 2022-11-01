// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract enemies {
    error NotAuthorised();
    error MaxedOut();
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
        uint level;
    }

    mapping(uint => EnemyDetails) public newEnemy;

    constructor(
        uint _multiplier,
        address _DAO,
        address _game
    ) {
        multiplier = _multiplier;
        DAO = _DAO;
        game = _game;
        id = 0;
    }

    function generateEnemy(
        uint maxLevel,
        uint basePower,
        uint levelMultiplier
    ) external {
        if (msg.sender != DAO) revert NotAuthorised();
        uint enemyId = ++id;
        EnemyDetails storage details = newEnemy[enemyId];
        details.maxLevel = maxLevel;
        details.basePower = basePower;
        details.levelMultiplier = levelMultiplier;
      
        //details.rewardId = enemyId; set to game id

        
    }
    function upgradeEnemy(uint _enemyID) external {
        EnemyDetails storage details = newEnemy[_enemyID];
        if(details.maxLevel==details.level) revert MaxedOut();
        details.level++;
    }

    function getStats(uint enemyID) external view returns (uint) {
        EnemyDetails storage details = newEnemy[enemyID];
        uint basePower = details.basePower;
        uint lvlMultiplier = details.levelMultiplier;
        uint totalMultiplier = (((100 + lvlMultiplier) ^ details.level) / 100) ^ details.level;
        uint totalStat = basePower * totalMultiplier;
        return totalStat;
    }
}

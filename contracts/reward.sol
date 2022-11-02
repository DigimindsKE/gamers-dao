// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "./erc1155currencyminter.sol";
import "./enemies.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
struct RewardPool {
    uint[] tokenIDs;
    uint[] baseRewards;
}

contract rewards is VRFConsumerBaseV2{
VRFCoordinatorV2Interface COORDINATOR;

    bytes32 public keyHash;
    
    uint16 requestConfirmations = 3;
    uint64 subscriptionID;
    uint256 public fee;
    uint256 public randomResult;

    address vrfCoordinator;
    address private currencyMinterAddress;
    address private managementContract;
    

    //Visibility?
    uint private poolID;
    mapping(uint => RewardPool)  poolDetails;
    
    constructor(address _currencyAddress, address _managementContract, uint64 _subscriptionID, address _vrfCoordinator, bytes32 _keyHash) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        currencyMinterAddress = _currencyAddress;
        managementContract = _managementContract;
        subscriptionID = _subscriptionID;
        vrfCoordinator = _vrfCoordinator;
        keyHash=_keyHash;
    }

    //mintRewards can only be called by a game
    function mintRewards(uint256 _poolID, uint256 enemyLevel) external {
        //Check that the caller is a game on the management contract    
  

        //Request random number

        //Store details regarding mint using request ID


    }
    
    function receiveRandomWords() external {
        //Retrieve details for mint using request ID

        //Calculate tokenID

        //Calculate rewardAmount for tokenID

        //Mint
    }

    //The admin or DAO(not sure which rn) will call with an array of token IDs & an array of amounts that will be assigned to the next available ID
    function setBaseRewards(uint256[] memory ids, uint256[] memory amounts) external {
        uint id = poolID++;
        RewardPool storage details = poolDetails[id];
        details.baseRewards = amounts;
        details.tokenIDs = ids;      
    }

    function getRewardPoolInfo(uint _poolID) external view returns (RewardPool memory) {
        return poolDetails[_poolID];

    }
}

interface ICheckRewards{
    function getRewardPoolInfo(uint256 _poolID) external view returns(RewardPool memory);
}

contract get {
  function foo(address rewards, uint256 poolId) external {
    RewardPool memory details = ICheckRewards(rewards).getRewardPoolInfo(poolId); 
  }
}
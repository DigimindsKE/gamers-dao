// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "./erc1155currencyminter.sol";
import "./enemies.sol";
import "./RNG.sol";
import "@openzeppelin/contracts/utils/Context.sol";

struct RewardPool {
    uint[] tokenIDs;
    uint[] baseRewards;
}

contract rewards is RNG, Context {
    error InvalidAddress();

    uint public numerator;
    uint public denominator;
    uint public requestID;
    address private currencyMinterAddress;
    address private managementContract;

    struct MintDetails {
        address beingRewarded;
        uint256 enemyLevel;
        uint256 poolID;
    }

    mapping(uint256 => MintDetails) private onReturn;

    //Visibility?
    uint private poolID;
    mapping(uint => RewardPool) private poolDetails;

    constructor(address _currencyAddress, address _managementContract)
        RNG(subscriptionId, vrfCoordinator, keyHash)
    {
        if (_currencyAddress == address(0) || _managementContract == address(0))
            revert InvalidAddress();
        currencyMinterAddress = _currencyAddress;
        managementContract = _managementContract;
    }

    //mintRewards can only be called by a game
    function mintRewards(uint256 _poolID, uint256 enemyLevel) external {
        //Check that the caller is a game on the management contract

        //Request random number
        uint _requestID = requestRandomWords(1, 200000);

        //Store details regarding mint using request ID
        MintDetails storage details = onReturn[_requestID];
        details.beingRewarded = _msgSender();
        details.enemyLevel = enemyLevel;
        details.poolID = _poolID;

        requestID = _requestID;
    }

    function fulfillRandomWords() external {
        //Retrieve details for mint using request ID
        uint _requestID = requestID;
        MintDetails storage details = onReturn[_requestID];
        //Calculate tokenID

        //Calculate rewardAmount for tokenID
        uint poolId = details.poolID;
        uint[] memory baseRewards = poolDetails[poolId].baseRewards;
        uint enemyLevel = details.enemyLevel;
        //5% over base rewards per level
        uint levelMultiplier = (((100 + 5) ^ enemyLevel) / 100) ^ enemyLevel;
        uint totalRewards = baseRewards * levelMultiplier;
        //Mint
        erc1155CurrencyMinter minter = erc1155CurrencyMinter(
            currencyMinterAddress
        );
        minter.mintRewards(
            /*tokenID,*/
            totalRewards
        );
    }

    //The admin or DAO(not sure which rn) will call with an array of token IDs & an array of amounts that will be assigned to the next available ID
    function setBaseRewards(uint256[] memory ids, uint256[] memory amounts)
        external
    {
        uint id = poolID++;
        RewardPool storage details = poolDetails[id];
        details.baseRewards = amounts;
        details.tokenIDs = ids;
    }

    function getRewardPoolInfo(uint _poolID)
        external
        view
        returns (RewardPool memory)
    {
        return poolDetails[_poolID];
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual
        override
    {}
}

interface ICheckRewards {
    function getRewardPoolInfo(uint256 _poolID)
        external
        view
        returns (RewardPool memory);
}

contract get {
    function foo(address _rewards, uint256 poolId) external {
        RewardPool memory details = ICheckRewards(_rewards).getRewardPoolInfo(
            poolId
        );
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "./erc1155currencyminter.sol";
import "./enemies.sol";
import "./RNG.sol";
import "./multisig.sol";
import "@openzeppelin/contracts/utils/Context.sol";

struct RewardPool {
    uint[] tokenIDs;
    uint[] baseRewards;
}

contract rewards is RNG, Context {
    error InvalidAddress();
    error NotAuthorized();

    uint private poolID;
    uint public requestID;
    address private currencyMinterAddress;
    address private managementContract;

    struct MintDetails {
        address beingRewarded;
        uint256 enemyLevel;
        uint256 poolID;
    }
    multisig signer = multisig(managementContract);

    mapping(uint256 => MintDetails) private onReturn;

    //Visibility?

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
        if (!signer.gameApproved(msg.sender)) revert NotAuthorized();
        //Request random number
        uint _requestID = requestRandomWords(1, 200000);

        //Store details regarding mint using request ID
        MintDetails storage details = onReturn[_requestID];
        details.beingRewarded = _msgSender();
        details.enemyLevel = enemyLevel;
        details.poolID = _poolID;

        requestID = _requestID;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual
        override
    {
        //Retrieve details for mint using request ID
        uint _requestID = requestId;

        MintDetails storage details = onReturn[_requestID];
        uint poolId = details.poolID;
        RewardPool storage pool = poolDetails[poolId];

        //Calculate tokenID
        erc1155CurrencyMinter minter = erc1155CurrencyMinter(
            currencyMinterAddress
        );
        uint index = randomWords[0] % pool.tokenIDs.length;

        //Calculate rewardAmount for tokenID

        uint[] storage baseRewards = pool.baseRewards;
        uint[] storage _tokenIds = pool.tokenIDs;
        uint enemyLevel = details.enemyLevel;
        //5% over base rewards per level
        uint levelMultiplier = ((21) ^ enemyLevel) / (20 ^ enemyLevel);
        uint totalRewards = baseRewards[index] * levelMultiplier;
        //Mint

        minter.mintRewards(_tokenIds[index], totalRewards);
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
}

interface ICheckRewards {
    function getRewardPoolInfo(uint256 _poolID)
        external
        view
        returns (RewardPool memory);
}

/*contract get {
    function foo(address _rewards, uint256 poolId) external {
        RewardPool memory details = ICheckRewards(_rewards).getRewardPoolInfo(
            poolId
        );
    }
}  
*/

// Sources flattened with hardhat v2.12.0 https://hardhat.org

// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.7.3

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol@v4.7.3

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.7.3

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol@v4.7.3

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol@v4.7.3

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}


// File contracts/multisig.sol

pragma solidity 0.8.17;
//import './erc1155currencyminter.sol';
/*this contract is a multi-signature contract where we can
    -- add/delete signers
    An added signer will have the privilege status of a member
    -- a member can propose a vote 
    -- a member can vote for a proposal
    -- a member can submit a game contract for review by the Audited developers
    */
//for a user to propose an address as a signer, they have to be an approved member of the dao ecosystem
contract multisig is ERC1155Holder {
    event NewVote(uint256 voteId);
    event CompletedVote(uint256 voteId);
    event FailedVote(uint256 voteId);

    error EmptyArray();
    error NotAdmin();
    error NotActive();
    error NotAuthorised();
    error ZeroAddress();
    error AlreadyAuthorised();
    error AlreadyVoted();
    error AlreadyMinted();
    error AlreadyApproved();

    struct ProposalSigner {
        address proposedSigner;
        uint8 votesFor;
        uint8 votesAgainst;
        bool voteActive;
        bool removeOrAdd;
        mapping(address => bool) hasSigned;
       
    }

    //struct for currency proposal
    struct ProposalCurrency {
        uint currencyID;
        uint initialAmount;
        uint8 votesFor;
        uint8 votesAgainst;
        bool voteActive;
        mapping(address => bool) hasSigned;
    }
    //Game Proposal Struct
    struct ProposalGame {
        uint gameID;
        address gameAddress;
        uint8 votesFor;
        uint8 votesAgainst;
        bool voteActive;
        mapping(address => bool) hasSigned;
    }
    //address variable to store the address of the minter
    address public currencyMinterAddress;
    address public admin;
    address[] public signers;
    uint256 public voteID;
    uint256 private currencyVoteID;
    uint256 private gameVoteID;
    mapping(address => bool) public approvedSigner;
    mapping(uint => ProposalSigner) public proposal;

    //currency mappings
    mapping(uint => ProposalCurrency) public currencyProposal;
    mapping(uint => bool) public currencyApproved;

    //game mappings
    mapping (uint =>ProposalGame) public gameProposal;
    mapping (address =>bool) public gameApproved;

    //add the admin addresses as initial signers
    //added _minterAddress to get access to the minter contract
    constructor(address[] memory _addresses /*address _currencyAddress */) {
        admin = msg.sender;
      //  currencyMinterAddress = _currencyAddress;
        if (_addresses.length == 0) revert EmptyArray();

        signers = _addresses;
        for (uint i = 0; i < _addresses.length; ) {
            approvedSigner[_addresses[i]] = true;
            unchecked {
                i++;
            }
        }
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    modifier onlyApproved() {
        if (!approvedSigner[msg.sender]) revert NotAuthorised();
        _;
    }

    //set currencyminter address
  

//internal functions for signers

    function removeSigner() internal{

    }
/*
            PROPOSAL FUNCTIONS
*/
    //to propose a signer, the address will have voteActive boolean set to true in order to allow voting
    function proposeSigner(address _address, bool _toRemove)
        external
        onlyAdmin
    {
        if (approvedSigner[_address] && !_toRemove) revert AlreadyAuthorised();
        if (!approvedSigner[_address] && _toRemove) revert NotAuthorised();

        uint id = ++voteID;
        //Pull storage pointer to instance of struct into
        ProposalSigner storage details = proposal[id];
        details.proposedSigner = _address;
        details.voteActive = true;
        details.removeOrAdd = _toRemove;

        emit NewVote(id);
    }

    function proposeCurrency(uint _amount) external onlyAdmin {
        uint id = ++currencyVoteID;
        ProposalCurrency storage details = currencyProposal[id];
        if (currencyApproved[id]) revert AlreadyMinted();
        details.currencyID = id;
        details.initialAmount = _amount;
        details.voteActive = true;
        //currencyVoteID++;
        emit NewVote(id);
    }

    function proposeGame(address game_CA) external onlyAdmin
{
    if(game_CA==address(0)) revert ZeroAddress();
    uint id = ++gameVoteID;
    ProposalGame storage details = gameProposal[id];

        if(gameApproved[game_CA]) revert AlreadyApproved();
        details.gameAddress = game_CA;
        details.voteActive = true;
        emit NewVote(id);      
}



/*

        VOTING FUNCTIONS

*/
    function VoteforSigner(uint id, bool vote) external onlyApproved {
        ProposalSigner storage details = proposal[id];
        if (!details.voteActive) revert NotActive();
        if (details.hasSigned[msg.sender]) revert AlreadyVoted();

        details.hasSigned[msg.sender] = true;
      


        if (vote) {
            details.votesFor += 1;
        } else {
            details.votesAgainst += 1;
        }
        //If over 60% of signers have voted for
        if (((details.votesFor * 100) / signers.length) >= 60) {
            details.voteActive = false;

            emit CompletedVote(id);

            //If to remove
           if (details.removeOrAdd == false) {
                //Remove privileges
                approvedSigner[details.proposedSigner] = true;
            }
            
            else {
                approvedSigner[details.proposedSigner] = false;
                //pull signers from storage into memory
                address[] memory _signers = signers;

                for (uint i = 0; i < _signers.length; ) {
                    if (_signers[i] == details.proposedSigner) {
                        signers[i] = signers[_signers.length - 1];
                        signers.pop();
                    }

                    unchecked {
                        i++;
                    }
                } //If to add
            
            }
        } else if ((details.votesAgainst * 100) / signers.length > 40) {
            details.voteActive = false;
            emit FailedVote(id);
        }
    }

    function voteCurrency(uint id, bool _vote) external onlyApproved {
        ProposalCurrency storage details = currencyProposal[id];
        if (!details.voteActive) revert NotActive();
        if (details.hasSigned[msg.sender]) revert AlreadyVoted();
        details.hasSigned[msg.sender] = true;

        if (_vote) {
            details.votesFor += 1;
        } else {
            details.votesAgainst += 1;
        }
        if ((details.votesFor * 100) / signers.length >= 60) {
            details.voteActive = false;
            currencyApproved[id]=true;
            emit CompletedVote(id);
            
            
        
        } else if ((details.votesAgainst * 100) / signers.length > 40) {
            details.voteActive = false;
            emit FailedVote(id);
        }
    }
    function voteForGame(uint id, bool vote) external onlyApproved {
         ProposalGame storage details = gameProposal[id];
          if(!details.voteActive) revert NotActive();
          if(details.hasSigned[msg.sender]) revert AlreadyVoted();
            details.hasSigned[msg.sender] = true;  

            if (vote) {
            details.votesFor += 1;
        } else {
            details.votesAgainst += 1;
        }  
         if ((details.votesFor * 100) / signers.length >= 60) {
            details.voteActive = false;
           gameApproved[details.gameAddress]=true;
            
        } else if ((details.votesAgainst * 100) / signers.length > 40) {
            details.voteActive = false;
            emit FailedVote(id);
        }            
    }
}

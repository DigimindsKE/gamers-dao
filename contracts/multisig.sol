// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "erc1155currencyminter.sol";
/*this contract is a multi-signature contract where we can
    -- add/delete signers
    An added signer will have the privilege status of a member
    -- a member can propose a vote 
    -- a member can vote for a proposal
    -- a member can submit a game contract for review by the Audited developers
    */
//for a user to propose an address as a signer, they have to be an approved member of the dao ecosystem
contract multisig {
    event NewVote(uint256 voteId);
    event CompletedVote(uint256 voteId);
    event FailedVote(uint256 voteId);

    error EmptyArray();
    error NotAdmin();
    error NotActive();
    error NotAuthorised();
    error AlreadyAuthorised();
    error AlreadyVoted();

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
    //address variable to store the address of the minter
    address public currencyMinterAddress;
    address private admin;
    address[] public signers;
    uint256 private voteID;
    uint private currencyVoteID;
    mapping(address => bool) private approvedSigner;
    mapping(uint => ProposalSigner) private proposal;

    //currency mappings
    mapping (uint => ProposalCurrency) currencyProposal;
    mapping(uint=>bool) currencyApproved;

    //add the admin addresses as initial signers
    //added _minterAddress to get access to the minter contract
    constructor(address[] memory _addresses, address _currencyAddress) {
        admin = msg.sender;
        currencyMinterAddress=_currencyAddress;
        if (_addresses.length == 0) revert EmptyArray();

        signers = _addresses;
        for (uint i = 0; i < _addresses.length;) {
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

    //to propose a signer, the address will have voteActive boolean set to true in order to allow voting
    function proposeSigner(address _address, bool _toRemove)
        external
        onlyadmin
    {
        if (approvedSigner[_address] && !_toRemove) revert AlreadyAuthorised();
        if (!approvedSigner[_address] && _toRemove) revert NotAuthorised();

        uint id = ++voteID;
        //Pull storage pointer to instance of struct into
        ProposalSigner storage details = proposal[id];
        details.voteActive = true;
        details.removeOrAdd = _toRemove;

        emit NewVote(id);
    }

    function proposeCurrency(uint _amount) onlyAdmin {
        uint id=voteID+1;
        ProposalCurrency storage details = currencyProposal[id];
        if(currencyApproved[id]) revert AlreadyMinted();
        details.currencyId=id;
        details.initialAmount = _amount;
        details.voteActive = true;
         voteID++;
        
    }

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
        if ((details.votesFor * 100) / signers.length >= 60) {
            details.voteActive = false;

            emit CompletedVote(id);

            //If to remove
            if (details.removeOrAdd) {
                //Remove privilledges
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
            } else {
                approvedSigner[details.proposedSigner] = true;
            }
        } else if ((details.votesAgainst * 100) / signers.length >= 60) {
            details.voteActive = false;
            emit FailedVote(id);
        }
    }
    function voteCurrency(uint _id,bool _vote) external onlyApproved {
        ProposalCurrency details = currencyProposal[id];
        if(!details.voteActive) revert NotActive();
        if(details.hasSigned[msg.sender]) revert AlreadyVoted();
        details.hasSigned[msg.sender]=true;

         if (_vote) {
            details.votesFor += 1;
        } else {
            details.votesAgainst += 1;
        }
        if ((details.votesFor * 100) / signers.length >= 60) {
            details.voteActive = false;

            emit CompletedVote(id);
            erc1155CurrencyMinter minter = erc1155CurrencyMinter(currencyMinterAddress);
            minter.addToken(details.initialAmount);
        }
       else if((details.votesAgainst * 100) / signers.length >= 40){
             details.voteActive = false;
             emit FailedVote(id);
        }
    }
}

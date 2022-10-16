// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

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
    error NotOwner();
    error NotActive();
    error NotAuthorised();
    error AlreadyAuthorised();
    error AlreadyVoted();

    struct proposalSigner {
        address proposedSigner;
        bool voteActive;
        uint8 votesFor;
        uint8 votesAgainst;
        bool removeOrAdd;
        mapping(address=>bool) hasSigned;
    }
    address private owner;
    address[] public signers;
    uint256 private voteID;
    mapping(address => bool) private approvedSigner;
    mapping(uint => proposalSigner) private proposal;

    mapping(address => bool) private hasVoted;


    //add the owner addresses as initial signers
    constructor(address[] memory _addresses) {
        owner = msg.sender;
        if(
            _addresses.length == 0) revert EmptyArray();
            
        signers = _addresses;
        for (uint i = 0; i < _addresses.length; i++) {
            approvedSigner[_addresses[i]] = true;
        unchecked {
            i++;
        }
        }
    }

    modifier onlyOwner() {
        if(msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyApproved() {
        if(!approvedSigner[msg.sender]) revert NotAuthorised();
        _;
    }

    //to propose a signer, the address will have voteActive boolean set to true in order to allow voting
    function proposeSigner(address _address, bool _toRemove) public onlyOwner {
        if(approvedSigner[_address] && !_toRemove) revert AlreadyAuthorised();
        if(!approvedSigner[_address] && _toRemove) revert NotAuthorised();
        

        uint id =++voteID;
//Pull storage pointer to instance of struct into 
        proposalSigner storage details = proposal[id];
        details.voteActive = true;
        details.removeOrAdd = _toRemove;

        emit NewVote(id);

    }

    function VoteforSigner(uint id, bool vote) external onlyApproved {
       proposalSigner storage details = proposal[id];
        if(!details.voteActive) revert NotActive();
        if(details.hasSigned[msg.sender]) revert AlreadyVoted();
       
       details.hasSigned[msg.sender] = true;

        if(vote){
            details.votesFor += 1;
        }else {
            details.votesAgainst += 1;
        }
        //If over 60% of signers have voted for
        if((details.votesFor * 100 ) / signers.length >= 60 ){
            details.voteActive = false;

            emit CompletedVote(id);

            //If to remove
            if(details.removeOrAdd){

                //Remove privilledges
                approvedSigner[details.proposedSigner] = false;

                //pull signers from storage into memory
                address[] memory _signers = signers;

                for(uint i = 0; i< _signers.length;){
                    if(_signers[i] == details.proposedSigner){
                        signers[i] = signers[_signers.length -1];
                        signers.pop();
                    }

                    unchecked{
                        i++;
                    }
                }//If to add
            }else {
                approvedSigner[details.proposedSigner] = true;
            }
        } else if((details.votesAgainst * 100 ) / signers.length >= 60){
            details.voteActive = false;
            emit FailedVote(id);
        }

    }

}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

contract multisig {
    /*this contract is a multi-signature contract where we can
    -- add/delete signers
    An added signer will have the privilege status of a member
    -- a member can propose a vote 
    -- a member can vote for a proposal
    -- a member can submit a game contract for review by the Audited developers
    */
    //for a user to propose an address as a signer, they have to be an approved member of the dao ecosystem

    address[] internal owners;
    //mapping to assign Approved signers
    mapping(address => bool) public approvedSigner;

    modifier onlyApproved() {
        require(approvedSigner[msg.sender], "Not Authorized");
        _;
    }

    //add the owner addresses as initial signers
    constructor(address[] memory Addresses) {
        require(
            Addresses.length > 0,
            "Not enough signers to deploy the contract"
        );
        owners = Addresses;
        for (uint i = 0; i < owners.length; i++) {
            approvedSigner[owners[i]] = true;
        }
    }

    uint totalvotes = owners.length;
    uint minVotes = totalvotes / 2 + 1;
    struct proposalSigner {
        bool voteActive;
        uint8 votesFor;
        uint8 votesAgainst;
    }
    //proposing a vote to add signer
    mapping(address => proposalSigner) private proposal;

    //proposing a vote to remove signer
    mapping(address => proposalSigner) private outProposal;

    mapping(address => bool) private hasVoted;

    //to propose a signer, the address will have voteActive boolean set to true in order to allow voting
    function proposeSigner(address Address) public onlyApproved {
        require(!approvedSigner[Address], "already A signer");
        proposal[Address].voteActive = true;
    }

    function VoteforSigner(address Address, bool Vote) external onlyApproved {
        require(
            proposal[Address].voteActive,
            "Voting for this Address is Inactive"
        );
        require(!hasVoted[msg.sender], "Already voted");
        uint8 YesCount;
        uint8 NoCount;
        if (Vote) {
            YesCount++;
        } else {
            NoCount++;
        }
        proposal[Address].votesFor += YesCount;
        proposal[Address].votesAgainst += NoCount;

        if (proposal[Address].votesFor >= minVotes) {
            approvedSigner[Address] = true;
        }
    }

    //vote out  Signer function
    function VoteOutSigner(address Address, bool Vote) external onlyApproved {
        require(approvedSigner[Address], "Not A valid Address");
        require(!hasVoted[msg.sender], "Already voted");
        uint8 YesCount;
        uint8 NoCount;
        if (Vote) {
            YesCount++;
        } else {
            NoCount++;
        }
        outProposal[Address].votesFor += YesCount;
        outProposal[Address].votesAgainst += NoCount;
        if (outProposal[Address].votesFor >= minVotes) {
            approvedSigner[Address] = false;
        }
    }
}

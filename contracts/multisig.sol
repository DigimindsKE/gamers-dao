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
mapping (address => bool) public approvedSigner;
uint minVotes;

modifier onlyApproved {
    require(approvedSigner[msg.sender],"Not Authorized");
    _;
}
constructor(address[] memory Addresses){
    require(Addresses.length>0,"Not enough signers to deploy the contract");
    owners=Addresses;
    for (uint i = 0; i < owners.length; i++) {
    approvedSigner[owners[i]]=true;
}
}
struct proposalSigner {
     bool voteActive;
     uint8 votesFor;
     uint8 votesAgainst;
}

mapping(address=>proposalSigner) private proposal;
mapping(address=>bool) hasVoted;
function VoteforSigner(address Address, bool Vote) external onlyApproved{
    require(!hasVoted[msg.sender],"Already voted");
uint8 YesCount;
uint8 NoCount;
if(Vote){
    YesCount++;
}else{
    NoCount++;
}
proposal[Address].votesFor +=YesCount;
proposal[Address].votesAgainst+=NoCount;
}

function addSignerAddress(address Address) internal {
    if(proposal[Address].votesFor>proposal[Address].votesAgainst){
        approvedSigner[Address]=true;
    }
}
}

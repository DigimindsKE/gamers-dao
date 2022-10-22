const { expect } = require("chai");
const { ethers } = require("ethers");

describe("multisig DAO", function () {
    let nftdeploy;
    beforeEach(async function () {
        [owner, user, user1, user2] = await hre.ethers.getSigners();
        const multisig = await hre.ethers.getContractFactory("multisig");
        Multisig = await multisig.deploy([owner.address, user.address, user1.address]);
     
    })
    it("Ownershould be able to propose a signer", async function () {
        let instance =await Multisig.deployed();
        const proposalid =await instance.propose(user2.address,false).id;

        expect(await instance.proposal[proposalid].voteActive==true);  
        })

})

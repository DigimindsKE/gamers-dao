const { expect } = require("chai");
const { ethers } = require("ethers");

describe("multisig DAO", function () {
    let nftdeploy;
    beforeEach(async function () {
        
        // await minter.deployed();
        [owner, user, user1, user2] = await hre.ethers.getSigners();
        const currencyMinter = await hre.ethers.getContractFactory("erc1155CurrencyMinter");

        const multisig = await hre.ethers.getContractFactory("multisig");
        Multisig = await multisig.deploy([owner.address, user.address, user1.address]);

        Minter  =await currencyMinter.deploy(Multisig.address);

    })
    it("Admin should be able to propose a signer", async function () {
        let pSigner = await Multisig.proposeSigner(user2.address, false);
        let resp = await pSigner.wait()
        //    console.log("2: ",resp.events[0].args.voteId.toString())
        const id = resp.events[0].args.voteId.toString()
        let active = (await Multisig.proposal(id)).voteActive;
        console.log(active);
        expect(active).to.equal(true);
    })

    it("Admin should be able to propose a currency", async function () {
        let pcurrency = await Multisig.proposeCurrency(100000);
        let resp = await pcurrency.wait()    //   const id = pcurrency.id;
        const id = resp.events[0].args.voteId.toString();
                console.log(id)
        expect((await Multisig.currencyProposal(id)).voteActive).to.equal(true);
    })

    it("Admin should be able to propose a game", async function () {
        const testAddress = "0x34d235fC47593EA72A493804FEd11C1499A7826C";
        await Multisig.proposeGame(testAddress);
        // console.log(pgame)
        // const id = pgame.id;
        expect((await Multisig.gameProposal(1)).voteActive).to.equal(true);
    })

    it("A voted in address should be a signer", async function () {
        let pSigner = await Multisig.proposeSigner(user2.address, false);
        let resp = await pSigner.wait()
        
        const id = resp.events[0].args.voteId.toString()
     //   console.log(id)
        //    const id = pSigner.voteID;
       // console.log((await Multisig.proposal(1)).removeOrAdd)
        await Multisig.connect(owner).VoteforSigner(id, true);
        await Multisig.connect(user1).VoteforSigner(id, true);
      // await Multisig.connect(user).VoteforSigner(id, true);
        //console.log((await Multisig.proposal(1)).proposedSigner)
        //  await Multisig.connect(user1).VoteforSigner(id, true);
         
         //console.log(await Multisig.approvedSigner(user2.address))  
        expect(await Multisig.approvedSigner(user2.address)).to.equal(true);
    
    })

    it("A voted currency should be minted", async function () {
        await Multisig.proposeCurrency(100000);
        await Multisig.setMinterAddress(Minter.address);
        await Multisig.connect(user1).voteCurrency(1, true);
        
        await Multisig.connect(user).voteCurrency(1, true);
        
        expect(await Multisig.currencyApproved(1)).to.equal(true);
       
    })


        it("A voted in game should be allowed", async function(){
            const testAddress = "0x34d235fC47593EA72A493804FEd11C1499A7826C";
      let game = (await Multisig.proposeGame(testAddress));
                let resp = await game.wait();
           const id = resp.events[0].args.voteId.toString()
             console.log(id)   
            await Multisig.connect(user).voteForGame(id, true);
            await Multisig.connect(user1).voteForGame(id, true);

            expect(await Multisig.gameApproved(testAddress)) .to.equal(true);
        })

        it("A voted out Signer should be removed", async function(){
            let pSigner = await Multisig.proposeSigner(user1.address, true);
            let resp = await pSigner.wait()
            
            const id = resp.events[0].args.voteId.toString()
           
            await Multisig.connect(owner).VoteforSigner(id, true);
            await Multisig.connect(user1).VoteforSigner(id, true);
     
             
             console.log(await Multisig.approvedSigner(user2.address))  
            expect(await Multisig.approvedSigner(user1.address)).to.equal(false);            
        })
})

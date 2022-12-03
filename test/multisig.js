const { expect } = require("chai");
const { ethers } = require("ethers");

describe("multisig DAO", function () {
    let nftdeploy;
    beforeEach(async function () {
        //const currencyMinter = await hre.ethers.getContractFactory("erc1155CurrencyMinter")

        // await minter.deployed();
        [owner, user, user1, user2] = await hre.ethers.getSigners();

        const multisig = await hre.ethers.getContractFactory("multisig");
        Multisig = await multisig.deploy([owner.address, user.address, user1.address]);

        //const minter  =await currencyMinter.deploy(Multisig.address, Multisig.address);

    })
    it("Admin should be able to propose a signer", async function () {
        let pSigner = await Multisig.proposeSigner(user2.address, false);
        let resp = await pSigner.wait()
        //    console.log("2: ",resp.events[0].args.voteId.toString())
        const id = resp.events[0].args.voteId.toString()

        expect(await Multisig.proposal(id).voteActive == true);
    })

    it("Admin should be able to propose a currency", async function () {
        let pcurrency = await Multisig.proposeCurrency(100000);
        let resp = await pcurrency.wait()    //   const id = pcurrency.id;
        const id = resp.events[0].args.voteId.toString();
                console.log(id)
        expect((await Multisig.currencyProposal(1).voteActive) == true);
    })

    it("Admin should be able to propose a game", async function () {
        const testAddress = "0x34d235fC47593EA72A493804FEd11C1499A7826C";
        let pgame = await Multisig.proposeGame(testAddress);
        // console.log(pgame)
        // const id = pgame.id;
        expect(await Multisig.gameProposal(1).voteActive == true);
    })

    it("A voted in address should be a signer", async function () {
        let pSigner = await Multisig.proposeSigner(user2.address, false);
        let resp = await pSigner.wait()
        
        const id = resp.events[0].args.voteId.toString()
        console.log(id)
        //    const id = pSigner.voteID;

        await Multisig.connect(owner).VoteforSigner(id, false);
        await Multisig.connect(user1).VoteforSigner(id, false);
       // await Multisig.connect(user).VoteforSigner(id, true);

        //  await Multisig.connect(user1).VoteforSigner(id, true);

        expect((await Multisig.approvedSigner(user2.address)) == true);

    })

})

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
    it("Owner should be able to propose a signer", async function () {
        await Multisig.deployed();
       let pSigner = await Multisig.proposeSigner(user2.address,false);
       const id = pSigner.id;
       
  

        expect(await Multisig.proposal(id).voteActive==true);   
        })
    
    it ("Admin should be able to propose a currency", async function(){
        await Multisig.deployed();
         let pcurrency= await Multisig.proposeCurrency(100000);
          const id = pcurrency.id;
          
          expect(await Multisig.currencyProposal(id).voteActive ==true);
    })

    
    it ("Admin should be able to propose a game", async function(){
            await Multisig.deployed()
            const testAddress = "0x34d235fC47593EA72A493804FEd11C1499A7826C";
            let pgame = await Multisig.proposeGame(testAddress);
            const id = pgame.id;
            expect(await Multisig.gameProposal(id).voteActive == true);
    })

})

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const subscriptionID = 7908;
  const vrfCoordinator = "0x2ca8e0c643bde4c2e08ab1fa0da3401adad7734d"
  const KeyHash = "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15"
  const multisigAddress = "0x22dAB01f8FCF47D14280AdB21586Da64969991c8"
  const Currency ="0x1973D0f73253c3F0D94B83B75103A6BDe411B86c"
  //[admin, user1, user2] = ["0x34d235fC47593EA72A493804FEd11C1499A7826C","0x11ec36418bE9a610904D1409EF0577b645104881", "0xa5065676D5d12b202dF10f479F2DDD62234b91b9"]
  
  const ms = await hre.ethers.getContractFactory("multisig");
  const Multisig = await ms.deploy(["0x34d235fC47593EA72A493804FEd11C1499A7826C","0x11ec36418bE9a610904D1409EF0577b645104881", "0xa5065676D5d12b202dF10f479F2DDD62234b91b9"]);
  await Multisig.deployed();
  console.log("Multisig Contract Address ", Multisig.address)

  const curr = await hre.ethers.getContractFactory("erc1155CurrencyMinter");
  const currency = await curr.deploy(Multisig.address);
  await currency.deployed()
  console.log("currency Minter CA:", Currency.address);

  const token = await hre.ethers.getContractFactory("spnToken")
  const Token = await token.deploy(1000000)
  await Token.deployed();
  console.log("Governance Token: ", Token.address)
  
  const char = await hre.ethers.getContractFactory("Character")
  const Character= await char.deploy(Multisig.address)
  await Character.deployed();
  console.log("Character Minter: ", Character.address)

  const weapon = await hre.ethers.getContractFactory("erc721BlacksmithMinter")
  const Weapons = await weapon.deploy(multisigAddress,Currency,subscriptionID,vrfCoordinator,KeyHash)
  await Weapons.deployed();
  console.log("Weapon Minter: ", Weapons.address)

  const effects = await hre.ethers.getContractFactory("erc1155EffectsMinter")
  const Effect = await effects.deploy(multisigAddress,subscriptionID,vrfCoordinator,KeyHash)
  await Effect.deployed();
  console.log("Effect Minter: ", Effect.address)


  const enemy = await hre.ethers.getContractFactory("enemies")
  const Enemies = await enemy.deploy(Multisig.address)
  await Enemies.deployed();
  console.log("Enemy: ", Enemies.address)

  const reward = await hre.ethers.getContractFactory("rewards")
  const Rewards = await reward.deploy(Currency.address,Multisig.address,subscriptionID,vrfCoordinator,KeyHash)
  await Rewards.deployed();
  console.log("Rewards: ", Token.address)

  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

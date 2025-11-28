// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // Debugging: Check if accounts are loaded
  const signers = await hre.ethers.getSigners();
  if (signers.length === 0) {
    console.error("❌ No accounts found! Check your .env file and PRIVATE_KEY variable.");
    console.error("Current Network:", hre.network.name);
    process.exit(1);
  }

  const [deployer] = signers;

  console.log("Deploying AlohaCoin with account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // ✅ Use the deployer's address for all wallets initially to secure control
  const devWallet = deployer.address;
  const marketingWallet = deployer.address;
  const reflectionPool = deployer.address;

  const AlohaCoin = await hre.ethers.getContractFactory("AlohaCoin");
  const token = await AlohaCoin.deploy(devWallet, marketingWallet, reflectionPool);

  await token.deployed();
  console.log("✅ AlohaCoin deployed to:", token.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
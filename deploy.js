// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying AlohaCoin with account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const devWallet = "0x5D8a4Cd28599b2897903FfA6850aF14Ce9f6F2f5"; // 🔁 Replace with your wallet
  const reflectionPool = "0x5D8a4Cd28599b2897903FfA6850aF14Ce9f6F2f5"; // 🔁 Replace with pool wallet or DAO multisig

  const AlohaCoin = await hre.ethers.getContractFactory("AlohaCoin");
  const token = await AlohaCoin.deploy(devWallet, reflectionPool);

  await token.deployed();
  console.log("✅ AlohaCoin deployed to:", token.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
const { upgrades, ethers } = require("hardhat");
const proxyAddress = "0xc8Ab8967226B14b338936Cb84524eaB2eCC3B36C";

async function main() {
  
  const BUSDPixelSafePool = await ethers.getContractFactory("BUSDVYNCSTAKE_V2");
  const bUSDPixelSafePool = await upgrades.upgradeProxy(proxyAddress, BUSDPixelSafePool);
  await bUSDPixelSafePool.deployed();

  console.log("deployed to:", bUSDPixelSafePool.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

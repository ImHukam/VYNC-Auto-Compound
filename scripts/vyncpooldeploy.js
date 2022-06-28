const { upgrades, ethers } = require("hardhat");

async function main() {
  
  const BUSDPixelSafePool = await ethers.getContractFactory("VYNCSTAKEPOOL");
  const bUSDPixelSafePool = await upgrades.deployProxy(BUSDPixelSafePool);
  await bUSDPixelSafePool.deployed();

  console.log("deployed to:", bUSDPixelSafePool.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

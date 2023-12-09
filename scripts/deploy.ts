import { formatEther, parseEther } from "viem";
import hre from "hardhat";

async function main() {
  
  const inDance = await hre.viem.deployContract("InDance", [], {});

  console.log(
    `InDance deployed to ${inDance.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { formatEther, parseEther } from "viem";
import hre from "hardhat";

async function main() {

  const balance = await (await hre.viem.getPublicClient()).getBalance({
    address: '0x05221C4fF9FF91F04cb10F46267f492a94571Fa9'
  });

  console.log(balance);
  
  const inDance = await hre.viem.deployContract("InDance");

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

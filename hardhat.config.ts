import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    scrollTestnet: {
      url: "https://sepolia-rpc.scroll.io/",
      accounts:
        [process.env.PRIVATE_KEY!],
    },

  },
  etherscan: {
    apiKey: {
      scrollTestnet: 'abc',
    },
    customChains: [
      {
        network: 'scrollTestnet',
        chainId: 534351,
        urls: {
          apiURL: 'https://sepolia-blockscout.scroll.io/api',
          browserURL: 'https://sepolia-blockscout.scroll.io/',
        },
      },
    ],
  },

};

export default config;

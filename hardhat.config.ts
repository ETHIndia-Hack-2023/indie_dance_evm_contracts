import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import * as dotenv from "dotenv";
import {defineChain} from "viem";
import { viem } from "hardhat";

export const x1net = defineChain({
  id: 195,
  name: 'X1',
  network: 'x1',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: {
      http: ['https://testrpc.x1.tech'],
      webSocket: ['wss://x1testws.okx.com'],
    },
    public: {
      http: ['https://testrpc.x1.tech'],
      webSocket: ['wss://x1testws.okx.com'],
    },
  },
  blockExplorers: {
    default: { name: 'Explorer', url: 'https://www.oklink.com/x1-test' },
  },
  contracts: {
    multicall3: {
      address: '0xcA11bde05977b3631167028862bE2a173976CA11',
      blockCreated: 5882,
    },
  },
})


dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    scrollTestnet: {
      url: "https://sepolia-rpc.scroll.io/",
      accounts:
        [process.env.PRIVATE_KEY!],
    },
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts:
        [process.env.PRIVATE_KEY!],
      chainId: 44787
    },
    mantleTestnet: {
      url: "https://rpc.testnet.mantle.xyz",
      accounts:
        [process.env.PRIVATE_KEY!],
      chainId: 5001
    },
    X1: {
      url: "https://testrpc.x1.tech",
      accounts: [process.env.PRIVATE_KEY!],
      chainId: 195,
      chains: x1net
    },
  },
  etherscan: {
    apiKey: {
      scrollTestnet: 'abc',
      alfajores: 'BW2YCZBG9MZUQ35ZZV67498PXEKAZ7FVQF',
      mantleTestnet: 'aaa'
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
      {
        network: "alfajores",
        chainId: 44787,
        urls: {
          apiURL: "https://api-alfajores.celoscan.io/api",
          browserURL: "https://alfajores.celoscan.io",
        },
      },
      {
        network: "mantleTestnet",
        chainId: 5001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz",
        },
      },
    ],
  },

};

export default config;

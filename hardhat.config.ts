import dotenv from 'dotenv';
dotenv.config();
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-deploy';
import '@nomiclabs/hardhat-ethers';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
          },
          outputSelection: {
            '*': {
              '*': ['storageLayout'],
            },
          },
        },
      },
    ],
  },
  namedAccounts: {
    deployer: 0,
    tokenBeneficiary: 1,
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts:
        process.env.PRIVATE_KEY !== undefined
          ? [`0x` + process.env.PRIVATE_KEY]
          : [],
    },
  },
  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5',
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
  },
};

export default config;

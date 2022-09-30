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
};

export default config;

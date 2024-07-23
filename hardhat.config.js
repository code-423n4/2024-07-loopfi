require('dotenv').config();
require('@nomicfoundation/hardhat-foundry');
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
const tenderly = require('@tenderly/hardhat-tenderly');
tenderly.setup({automaticVerifications: false});

const {subtask} = require('hardhat/config');
const {TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS} = require('hardhat/builtin-tasks/task-names')

// don't compile tests and scripts
subtask(TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS).setAction(async (_, __, runSuper) => {
  const paths = await runSuper();
  return paths.filter(p => !(p.endsWith('.t.sol') && p.endsWith('.s.sol')));
});

module.exports = {
  solidity: {
    version: '0.8.19',
    settings: {
      optimizer: {
        enabled: true,
        runs: 100
      }
    }
  },
  tenderly: {
    username: process.env.TENDERLY_USERNAME,
    project: process.env.TENDERLY_PROJECT,
    privateVerification: false,
    automaticVerifications: true
  },
  networks: {
    local: {
      url: 'http://127.0.0.1:8545',
      allowUnlimitedContractSize: true,
    },
    hardhat: {
        allowUnlimitedContractSize: true,
        forking: {
            url: process.env.MAINNET_RPC_URL,
        }
    },
    tenderly: {
      url: process.env.TENDERLY_FORK_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    }
  }
};

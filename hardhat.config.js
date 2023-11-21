require("dotenv").config();
require('hardhat-deploy');

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');

const createIpOrg = require("./script/hardhat/createIpOrg.js");
const createIPAsset = require("./script/hardhat/createIPAsset.js");
const batchUploader = require("./script/hardhat/batchUploader.js");
const namespacedStorageKey = require("./script/hardhat/namespacedStorageKey.js");
const { task } = require("hardhat/config");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task('sp:create-iporg')
    .addPositionalParam('name', 'Franchise name')
    .addPositionalParam('symbol', 'Franchise symbol')
    //.addPositionalParam('tokenURI', 'Franchise token URI (arweave URL with metadata)')
    .addOptionalParam('events', 'Show events in the tx receipt', false, types.boolean)
    .setDescription('Create an ipOrg contract and its initial definition')
    .setAction(createIpOrg);

task('sp:create-ip-asset')
    .addPositionalParam('franchiseId', 'Id of the Franchise to create the IP Asset in, as given by FranchiseRegistry contract')
    .addPositionalParam('ipAssetType', 'STORY, CHARACTER, ART, GROUP, LOCATION or ITEM')
    .addPositionalParam('name', 'IP Asset name')
    .addPositionalParam('description', 'IP Asset description')
    .addPositionalParam('mediaURL', 'IP Asset media URL')
    .addOptionalParam('events', 'Show events in the tx receipt', false, types.boolean)
    .setDescription('Mint IP Asset NFT and create IPAssetsRegistry contract')
    .setAction(createIPAsset);

task('sp:uploader')
    .addPositionalParam('franchiseId', 'Id of the Franchise to create the IP Assets in, as given by FranchiseRegistry contract')
    .addPositionalParam('receiver', 'Address that will receive the IP Assets')
    .addPositionalParam('filePath', 'path to the Json data')
    .addOptionalParam('batchSize', 'Number of blocks to upload in each batch', 100, types.int)
    .setDescription('Mass upload IP Assets from a Json file')
    .setAction(batchUploader);

task('sp:update-ip-assets')
    .addPositionalParam('franchiseId', 'Id of the Franchise to create the IP Assets in, as given by FranchiseRegistry contract')
    .addPositionalParam('tx', 'tx hash that created blocks')
    .addPositionalParam('filePath', 'path to the Json data')
    .setDescription('Update ids for blocks in the Json file')
    .setAction(batchUploader.updateIds);

task('sp:eip7201-key')
    .addPositionalParam('namespace', 'Namespace, for example erc7201:example.main')
    .setDescription('Get the namespaced storage key for https://eips.ethereum.org/EIPS/eip-7201')
    .setAction(namespacedStorageKey);

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    mainnet: {
      url: process.env.MAINNET_RPC_URL || "",
      chainId: 1,
      accounts: [process.env.MAINNET_PRIVATEKEY || "0x1234567890123456789012345678901234567890123456789012345678901234"]
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL || "",
      chainId: 5,
      accounts: [process.env.GOERLI_PRIVATEKEY || "0x1234567890123456789012345678901234567890123456789012345678901234"]
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      chainId: 11155111,
      accounts: [process.env.SEPOLIA_PRIVATEKEY || "0x1234567890123456789012345678901234567890123456789012345678901234"]
    },
    local: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
      }
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000
      }
    }
  },
  etherscan: {
    apiKey: `${process.env.ETHERSCAN_API_KEY}`
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};

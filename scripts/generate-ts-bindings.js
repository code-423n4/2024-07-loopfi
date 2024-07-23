const path = require('path');
const fs = require('fs');

const TARGET_DIRECTORY = path.join(__dirname, '..', 'bindings');
const FILE_NAME = 'human-readable-abis.ts';
const FILE_PATH = path.join(TARGET_DIRECTORY, FILE_NAME);

async function main() {
  const contracts = [
    // { name: 'Stablecoin', path: '../out/Stablecoin.sol/Stablecoin.json'},
    // { name: 'CDM', path: '../out/CDM.sol/CDM.json'},
    // { name: 'Buffer', path: '../out/Buffer.sol/Buffer.json'},
    { name: 'CDPVault', path: '../out/CDPVault.sol/CDPVault.json'},
    // { name: 'Minter', path: '../out/Minter.sol/Minter.json'},
    // { name: 'PSM', path: '../out/PSM.sol/PSM.json'},
    { name: 'Flashlender', path: '../out/Flashlender.sol/Flashlender.json'},
    { name: 'SwapAction', path: '../out/SwapAction.sol/SwapAction.json'},
    { name: 'PoolAction', path: '../out/PoolAction.sol/PoolAction.json'},
    { name: 'PositionAction20', path: "../out/PositionAction20.sol/PositionAction20.json"},
    { name: 'PositionAction4626' , path: '../out/PositionAction4626.sol/PositionAction4626.json'},
    { name: 'PRBProxyRegistry', path: '../out/IPRBProxyRegistry.sol/IPRBProxyRegistry.json' },
    { name: 'PRBProxy', path: '../out/PRBProxy.sol/PRBProxy.json' },
    { name: 'ERC20Permit', path: '../out/ERC20Permit.sol/ERC20Permit.json' },
    { name: 'ERC20', path: '../out/ERC20.sol/ERC20.json' },
    { name: 'ERC4626', path: '../out/ERC4626.sol/ERC4626.json' },
    { name: 'AuraVault' , path: '../out/AuraVault.sol/AuraVault.json'},
    { name: 'ISignatureTransfer', path: '../out/ISignatureTransfer.sol/ISignatureTransfer.json' },
    { name: 'MultiFeeDistribution', path: '../out/MultiFeeDistribution.sol/MultiFeeDistribution.json' },
    { name: 'EligibilityDataProvider', path: '../out/EligibilityDataProvider.sol/EligibilityDataProvider.json' },
    { name: 'ChefIncentivesController', path: '../out/ChefIncentivesController.sol/ChefIncentivesController.json'},
    { name: 'VaultRegistry', path: '../out/VaultRegistry.sol/VaultRegistry.json'},
    { name: 'LoopToken', path: '../out/ERC20Mock.sol/ERC20Mock.json'},
    { name: 'PriceProvider', path: '../out/Tokenomics.t.sol/MockPriceProvider.json'},
    { name: 'BalancerPool', path: '../out/IBalancerVault.sol/IVault.json'},
    { name: 'PoolV3', path: '../out/PoolV3.sol/PoolV3.json'},
  ];

  const abis = {};
  contracts.map(({ name, path }) => {
    const jsonABI = require(path);
    abis[name] = [...jsonABI.abi];
  });

  const objectEntries = Object.entries(abis).map(([key, value]) => {
    return `${key}: ${JSON.stringify(value)} as const`;
  });

  const objectAsString = `export const abis = {\n  ${objectEntries.join(',\n  ')}\n};\n`;

  fs.mkdir(TARGET_DIRECTORY, { recursive: true }, (err) => {
    fs.writeFile(FILE_PATH, objectAsString, (err) => {
      if (err) {
        console.error('Error writing file:', err);
      } else {
        console.log(`TypeScript bindings created at ${FILE_PATH}`);
      }
    });
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
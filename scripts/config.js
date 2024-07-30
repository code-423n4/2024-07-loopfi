const toWad = ethers.utils.parseEther;

// 1.00**(1/(60*60*24*366)) * 1e18, 0 decimals

module.exports = {
  "Core": {
    "CDM": {
      "initialGlobalDebtCeiling": toWad('100000000'),
    },
    "PSM": {
      "PSM_rETH": {
        "collateral": "0xae78736Cd615f374D3085123A210448E74Fc6393",
        "debtCeiling": toWad('100000000')
      },
      "PSM_stETH": {
        "collateral": "0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84",
        "debtCeiling": toWad('100000000')
      }
    },
    "Flashlender": {
      "constructorArguments": {
        "protocolFee_": toWad('0')
      },
      "initialDebtCeiling": toWad('100000000'),
    },
    "PRBProxyRegistry": "0x584009E9eDe26e212182c9745F5c000191296a78",
    "Actions": {
      "SwapAction": {
        "constructorArguments": {
          "balancerVault": "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
          "uniV3Router": "0xE592427A0AEce92De3Edee1F18E0157C05861564",
          "pendleRouter": "0x00000000005BBB0EF59571E58418F9a4357b68A0"
        }
      },
      "PoolAction": {
        "constructorArguments": {
          "balancerVault": "0xBA12222222228d8Ba445958a75a0704d566BF2C8",
          "pendleRouter": "0x00000000005BBB0EF59571E58418F9a4357b68A0"
        }
      }
    },
    "Gearbox": {
      "initialGlobalDebtCeiling": toWad('100000000'),
      "treasury": "0x0000000000000000000000000000000000000123"
    }
  },
  "Vendors": {
    "AuraVaults": {
      "Aura wstETH-WETH XXXX Deposit Vault": {
        "rewardPool": "0x2a14db8d09db0542f6a371c0cb308a768227d67d",
        "asset" : "0x93d199263632a4ef4bb438f1feb99e57b4b5f0bd",
        "feed": {
          "type": "MockOracle",
          "defaultPrice": toWad('1621')
        },
        "auraPriceOracle": "0xc29562b045D80fD77c69Bec09541F5c16fe20d9d",
        "maxClaimerIncentive": 100,
        "maxLockerIncentive": 100,
        "tokenName":  "Aura wstETH-WETH XXXX Deposit Vault",
        "tokenSymbol": "xxxxAurawstETH-WETH-vault"
      },
      "Aura wstETH-rETH-sfrxETH XXXX Deposit Vault": {
        "rewardPool": "0x032b676d5d55e8ecbae88ebee0aa10fb5f72f6cb",
        "asset" : "0x42ed016f826165c2e5976fe5bc3df540c5ad0af7",
        "feed":         {
          "type": "MockOracle",
          "defaultPrice": toWad('1607')
        },
        "auraPriceOracle": "0xc29562b045D80fD77c69Bec09541F5c16fe20d9d",
        "maxClaimerIncentive": 100,
        "maxLockerIncentive": 100,
        "tokenName":  "Aura wstETH-rETH-sfrxETH XXXX Deposit Vault",
        "tokenSymbol": "xxxxAurawstETH-rETH-sfrxETH-vault"
      }
    }
  },
  "Vaults": {
    "PendleVault": {
      "name": "Pendle CDP Vault",
      "description": "This vault allows for borrowing and lending of assets",
      "type": "CDPVault",
      "collateralType": "ERC20",
      "oracle": {
        "type": "PendleLPOracle",
        "deploymentArguments": {
          "ptOracle": "0x66a1096C6366b2529274dF4f5D8247827fe4CEA8",
          "market": "0xC8eDd52D0502Aa8b4D5C77361D4B3D300e8fC81c",
          "twap": 180,
          "aggregator": "0x5c9C449BbC9a6075A2c061dF312a35fd1E05fF22",
          "stalePeriod": 86400
        }
      },
      "tokenPot": "0xf0bb20865277aBd641a307eCe5Ee04E79073416C",
      "tokenIcon": "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIiB3aWR0aD0iMjRweCIgaGVpZ2h0PSIyNHB4IiB2aWV3Qm94PSIwIDAgMjQgMjQiIHZlcnNpb249IjEuMSI+CjxnIGlkPSJzdXJmYWNlMSI+CjxwYXRoIHN0eWxlPSIgc3Ryb2tlOm5vbmU7ZmlsbC1ydWxlOm5vbnplcm87ZmlsbDpyZ2IoMTUuMjk0MTE4JSw0NS44ODIzNTMlLDc5LjIxNTY4NiUpO2ZpbGwtb3BhY2l0eToxOyIgZD0iTSAxMiAyNCBDIDE4LjY0ODQzOCAyNCAyNCAxOC42NDg0MzggMjQgMTIgQyAyNCA1LjM1MTU2MiAxOC42NDg0MzggMCAxMiAwIEMgNS4zNTE1NjIgMCAwIDUuMzUxNTYyIDAgMTIgQyAwIDE4LjY0ODQzOCA1LjM1MTU2MiAyNCAxMiAyNCBaIE0gMTIgMjQgIi8+CjxwYXRoIHN0eWxlPSIgc3Ryb2tlOm5vbmU7ZmlsbC1ydWxlOmV2ZW5vZGQ7ZmlsbDpyZ2IoMTAwJSwxMDAlLDEwMCUpO2ZpbGwtb3BhY2l0eToxOyIgZD0iTSA1IDkuNTUwNzgxIEMgMy41NTA3ODEgMTMuMzk4NDM4IDUuNTUwNzgxIDE3Ljc1IDkuNDQ5MjE5IDE5LjE0ODQzOCBDIDkuNjAxNTYyIDE5LjI1IDkuNzUgMTkuNDQ5MjE5IDkuNzUgMTkuNjAxNTYyIEwgOS43NSAyMC4zMDA3ODEgQyA5Ljc1IDIwLjM5ODQzOCA5Ljc1IDIwLjQ0OTIxOSA5LjY5OTIxOSAyMC41IEMgOS42NTIzNDQgMjAuNjk5MjE5IDkuNDQ5MjE5IDIwLjgwMDc4MSA5LjI1IDIwLjY5OTIxOSBDIDYuNDQ5MjE5IDE5LjgwMDc4MSA0LjMwMDc4MSAxNy42NDg0MzggMy40MDIzNDQgMTQuODUxNTYyIEMgMS45MDIzNDQgMTAuMTAxNTYyIDQuNSA1LjA1MDc4MSA5LjI1IDMuNTUwNzgxIEMgOS4zMDA3ODEgMy41IDkuNDAyMzQ0IDMuNSA5LjQ0OTIxOSAzLjUgQyA5LjY1MjM0NCAzLjU1MDc4MSA5Ljc1IDMuNjk5MjE5IDkuNzUgMy44OTg0MzggTCA5Ljc1IDQuNjAxNTYyIEMgOS43NSA0Ljg1MTU2MiA5LjY1MjM0NCA1IDkuNDQ5MjE5IDUuMTAxNTYyIEMgNy40MDIzNDQgNS44NTE1NjIgNS43NSA3LjQ0OTIxOSA1IDkuNTUwNzgxIFogTSAxNC4zMDA3ODEgMy43NSBDIDE0LjM1MTU2MiAzLjU1MDc4MSAxNC41NTA3ODEgMy40NDkyMTkgMTQuNzUgMy41NTA3ODEgQyAxNy41IDQuNDQ5MjE5IDE5LjY5OTIxOSA2LjYwMTU2MiAyMC42MDE1NjIgOS40NDkyMTkgQyAyMi4xMDE1NjIgMTQuMTk5MjE5IDE5LjUgMTkuMjUgMTQuNzUgMjAuNzUgQyAxNC42OTkyMTkgMjAuODAwNzgxIDE0LjYwMTU2MiAyMC44MDA3ODEgMTQuNTUwNzgxIDIwLjgwMDc4MSBDIDE0LjM1MTU2MiAyMC43NSAxNC4yNSAyMC42MDE1NjIgMTQuMjUgMjAuMzk4NDM4IEwgMTQuMjUgMTkuNjk5MjE5IEMgMTQuMjUgMTkuNDQ5MjE5IDE0LjM1MTU2MiAxOS4zMDA3ODEgMTQuNTUwNzgxIDE5LjE5OTIxOSBDIDE2LjYwMTU2MiAxOC40NDkyMTkgMTguMjUgMTYuODUxNTYyIDE5IDE0Ljc1IEMgMjAuNDQ5MjE5IDEwLjg5ODQzOCAxOC40NDkyMTkgNi41NTA3ODEgMTQuNTUwNzgxIDUuMTQ4NDM4IEMgMTQuNDAyMzQ0IDUuMDUwNzgxIDE0LjI1IDQuODUxNTYyIDE0LjI1IDQuNjQ4NDM4IEwgMTQuMjUgMy45NDkyMTkgQyAxNC4yNSAzLjg1MTU2MiAxNC4yNSAzLjgwMDc4MSAxNC4zMDA3ODEgMy43NSBaIE0gMTIuMTQ4NDM4IDExLjMwMDc4MSBDIDE0LjI1IDExLjU1MDc4MSAxNS4zMDA3ODEgMTIuMTQ4NDM4IDE1LjMwMDc4MSAxMy44OTg0MzggQyAxNS4zMDA3ODEgMTUuMjUgMTQuMzAwNzgxIDE2LjMwMDc4MSAxMi44MDA3ODEgMTYuNTUwNzgxIEwgMTIuODAwNzgxIDE3Ljc1IEMgMTIuNzUgMTggMTIuNTk3NjU2IDE4LjE0ODQzOCAxMi4zOTg0MzggMTguMTQ4NDM4IEwgMTEuNjQ4NDM4IDE4LjE0ODQzOCBDIDExLjM5ODQzOCAxOC4xMDE1NjIgMTEuMjUgMTcuOTQ5MjE5IDExLjI1IDE3Ljc1IEwgMTEuMjUgMTYuNTUwNzgxIEMgOS41OTc2NTYgMTYuMzAwNzgxIDguODAwNzgxIDE1LjM5ODQzOCA4LjU5NzY1NiAxNC4xNDg0MzggTCA4LjU5NzY1NiAxNC4xMDE1NjIgQyA4LjU5NzY1NiAxMy44OTg0MzggOC43NSAxMy43NSA4Ljk0OTIxOSAxMy43NSBMIDkuODAwNzgxIDEzLjc1IEMgOS45NDkyMTkgMTMuNzUgMTAuMDk3NjU2IDEzLjg1MTU2MiAxMC4xNDg0MzggMTQuMDUwNzgxIEMgMTAuMzAwNzgxIDE0LjgwMDc4MSAxMC43NSAxNS4zNTE1NjIgMTIuMDUwNzgxIDE1LjM1MTU2MiBDIDEzIDE1LjM1MTU2MiAxMy42OTkyMTkgMTQuODAwNzgxIDEzLjY5OTIxOSAxNCBDIDEzLjY5OTIxOSAxMy4xOTkyMTkgMTMuMjUgMTIuODk4NDM4IDExLjg0NzY1NiAxMi42NDg0MzggQyA5Ljc1IDEyLjM5ODQzOCA4Ljc1IDExLjc1IDguNzUgMTAuMTAxNTYyIEMgOC43NSA4Ljg1MTU2MiA5LjY5OTIxOSA3Ljg1MTU2MiAxMS4xOTkyMTkgNy42NDg0MzggTCAxMS4xOTkyMTkgNi41IEMgMTEuMjUgNi4yNSAxMS4zOTg0MzggNi4xMDE1NjIgMTEuNTk3NjU2IDYuMTAxNTYyIEwgMTIuMzQ3NjU2IDYuMTAxNTYyIEMgMTIuNTk3NjU2IDYuMTQ4NDM4IDEyLjc1IDYuMzAwNzgxIDEyLjc1IDYuNSBMIDEyLjc1IDcuNjk5MjE5IEMgMTMuODk4NDM4IDcuODAwNzgxIDE0LjgwMDc4MSA4LjY0ODQzOCAxNSA5Ljc1IEwgMTUgOS44MDA3ODEgQyAxNSAxMCAxNC44NDc2NTYgMTAuMTQ4NDM4IDE0LjY0ODQzOCAxMC4xNDg0MzggTCAxMy44NDc2NTYgMTAuMTQ4NDM4IEMgMTMuNjk5MjE5IDEwLjE0ODQzOCAxMy41NTA3ODEgMTAuMDUwNzgxIDEzLjUgOS44OTg0MzggQyAxMy4yNSA5LjE0ODQzOCAxMi43NSA4Ljg1MTU2MiAxMS44NDc2NTYgOC44NTE1NjIgQyAxMC44NDc2NTYgOC44NTE1NjIgMTAuMzQ3NjU2IDkuMzAwNzgxIDEwLjM0NzY1NiAxMCBDIDEwLjM0NzY1NiAxMC42OTkyMTkgMTAuNjQ4NDM4IDExLjEwMTU2MiAxMi4xNDg0MzggMTEuMzAwNzgxIFogTSAxMi4xNDg0MzggMTEuMzAwNzgxICIvPgo8L2c+Cjwvc3ZnPgo=",
      "token": "0xC8eDd52D0502Aa8b4D5C77361D4B3D300e8fC81c",
      "tokenSymbol": "PENDLE-LPT",
      "tokenScale": toWad('1.0'),
      "protocolIcon": null,
      "deploymentArguments": {
        "constants": {
          "protocolFee": toWad('0.01'),
        },
        "configs": {
            "debtFloor": toWad('1000'),
            "liquidationRatio": toWad('1.05'),
            "liquidationPenalty": toWad('0.99'),
            "liquidationDiscount": toWad('0.98'),
            "roleAdmin": "deployer",
            "vaultAdmin": "deployer",
            "pauseAdmin": "deployer",
        },
        "debtCeiling": toWad('10000000')
      }
    },
  },
  "Tokenomics":{
    "MultiFeeDistribution": {
      "lockZap": "0x0000000000000000000000000000000000000123",
      "dao": "0x0000000000000000000000000000000000000123",
      "treasury": "0x0000000000000000000000000000000000000123",
      "rewardsDuration": 2592000, // 30 days in seconds
      "rewardsLookback": 432000, // 5 days in seconds
      "lockDuration": 2592000, // 30 days in seconds
      "burnRatio": 50000, // 50%
      "vestDuration": 2592000 // 30 days in seconds
    },
    "IncentivesController": {
      "rewardsPerSecond": "120000000000000000", // 0.12 in WAD
      "endingTimeCadence": "172800", // 2 days in seconds
      "rewardAmount": "10000000000000000000000000", // 10 milion in WAD
    }
  }
};

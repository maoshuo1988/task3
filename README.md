# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```

# 初始化项目
## 初始化 hardhat
```shell
npx hardhat --init
```
```
Which version of Hardhat would you like to use? · hardhat-2
What type of project would you like to initialize? · mocha-ethers-js
```
### 安装 openzepplin chainlink dotenv hardhat-deploy
更新package.json
```json
{
  "name": "task3",
  "version": "1.0.0",
  "devDependencies": {
    "@nomicfoundation/hardhat-chai-matchers": "^2.1.0",
    "@nomicfoundation/hardhat-ethers": "^3.1.0",
    "@nomicfoundation/hardhat-ignition": "^0.15.13",
    "@nomicfoundation/hardhat-ignition-ethers": "^0.15.14",
    "@nomicfoundation/hardhat-network-helpers": "^1.1.0",
    "@nomicfoundation/hardhat-toolbox": "^6.1.0",
    "@nomicfoundation/hardhat-verify": "^2.1.1",
    "@typechain/ethers-v6": "^0.5.1",
    "@typechain/hardhat": "^9.1.0",
    "chai": "^4.5.0",
    "ethers": "^6.15.0",
    "hardhat": "^2.26.3",
    "hardhat-gas-reporter": "^2.3.0",
    "solidity-coverage": "^0.8.16",
    "typechain": "^8.3.2"
  },
  "dependencies": {
    "@chainlink/contracts": "^1.5.0",
    "@openzeppelin/contracts": "^5.4.0",
    "@openzeppelin/contracts-upgradeable": "^5.4.0",
    "@openzeppelin/hardhat-upgrades": "^3.9.1",
    "dotenv": "^17.2.3",
    "hardhat-deploy": "^1.0.4"
  }
}

```
执行
```shell
npm i
```
### 配置 dotenv hardhat.config
添加 .env文件
```
INFURA_API_KEY=33045a1d50ff4aa2ba2321a76281a2ed
PK=92a23b579cfc51fb9579dfb9aadd9ceb03832216f2e96ede1cbf623ab20e3778
```

配置hardhat config
```json
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
    networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PK]
    }
  },
  namedAccounts: {
    deployer: 0,
    seller: 0,
    buyer: 0
  }
};



```

# 部署与测试

## 部署测试网
```shell
npx hardhat deploy --network sepolia
``` 
##
```shell
npx hardhat test
```
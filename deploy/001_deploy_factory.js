const { deployments, getNamedAccounts, upgrades, ethers } = require("hardhat");

const fs = require("fs");
const path = require("path");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, save } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying AuctionFactoryV1 with account:", deployer);
  const AuctionFactoryV1 = await ethers.getContractFactory("AuctionFactoryV1");
  const factoryV1 = await upgrades.deployProxy(AuctionFactoryV1, [], {
    deployer,
    initializer: "initialize",
  });
  await factoryV1.waitForDeployment();
  const proxyAddress = await factoryV1.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(
    proxyAddress
  );
  console.log("AuctionFactoryV1 deployed to:", proxyAddress);
  console.log("AuctionFactoryV1 implAddress to:", implAddress);

  const storePath = path.resolve(__dirname, "../cache/store/proxyFactory.json");
  fs.writeFileSync(
    storePath,
    JSON.stringify({
      proxyAddress,
      implAddress,
      abi: AuctionFactoryV1.interface.format("json"),
    })
  );

  await save("FactoryProxy", {
    abi: AuctionFactoryV1.interface.format("json"),
    address: proxyAddress,
    implAddress,
    args: [],
    log: true,
  });
};

module.exports.tags = ["AuctionFactoryV1"];

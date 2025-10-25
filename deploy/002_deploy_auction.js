const { deployments, getNamedAccounts, upgrades, ethers } = require("hardhat");

const fs = require("fs");
const path = require("path");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, save } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying AuctionV1 with account:", deployer);
  //为部署拍卖合约铸币
  const MockERC721 = await ethers.getContractFactory("MockERC721");
  const mockERC721 = await MockERC721.deploy();
  await mockERC721.waitForDeployment();
  const mockERC721Contract = await mockERC721.getAddress();
  await mockERC721.mint(deployer, 1);
  console.log("铸币完成");
  
  const duration = 86400; // 1 day
  const startPrice = ethers.parseEther("0.001");
  const nftContract = mockERC721Contract; // Mock NFT contract
  const nftToken = 1;
  const tokenAddress = ethers.ZeroAddress;
  const AuctionV1 = await ethers.getContractFactory("AuctionV1");
  const auctionV1 = await upgrades.deployProxy(
    AuctionV1,
    [duration, startPrice, nftContract, nftToken, tokenAddress],
    { deployer, initializer: "initialize" }
  );
  await auctionV1.waitForDeployment();
  const proxyAddress = await auctionV1.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(
    proxyAddress
  );
  console.log("AuctionV1 deployed to:", proxyAddress);
  console.log("AuctionV1 implAddress to:", implAddress);

  const storePath = path.resolve(__dirname, "../cache/store/proxyAuction.json");
  fs.writeFileSync(
    storePath,
    JSON.stringify({
      proxyAddress,
      implAddress,
      abi: AuctionV1.interface.format("json"),
    })
  );

  await save("AuctionProxy", {
    abi: AuctionV1.interface.format("json"),
    address: proxyAddress,
    args: [],
    log: true,
  });
};

module.exports.tags = ["AuctionV1"];

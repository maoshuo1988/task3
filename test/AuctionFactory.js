const { expect } = require("chai");
const { ethers, deployments, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

describe("AuctionFactory with UUPS Upgrade", function () {
  let factory, aution, factoryProxy, auctionProxy;
  let auctionImplementation;
  let owner, seller, buyer;

  beforeEach(async function () {
    [owner, seller, buyer] = await ethers.getSigners();

    // 获取工厂合约
    await deployments.fixture(["AuctionFactoryV1"]);
    factoryProxy = await deployments.get("FactoryProxy");
    factory = await ethers.getContractAt(
      "AuctionFactoryV1",
      factoryProxy.address
    );

    // 获取拍卖合约
    await deployments.fixture(["AuctionV1"]);
    auctionProxy = await deployments.get("AuctionProxy");
    auction = await ethers.getContractAt("AuctionV1", auctionProxy.address);

    auctionImplementation = await upgrades.erc1967.getImplementationAddress(
      auctionProxy.address
    );
    await factory
      .connect(owner)
      .setAuctionImplementation(auctionImplementation);
  });

  it("should factory setAuctionImplementation", async function () {
    const storePath = path.resolve(
      __dirname,
      "../cache/store/proxyAuction.json"
    );
    let txt = JSON.parse(fs.readFileSync(storePath));
    expect(txt.implAddress).to.equal(auctionImplementation);
  });

  it("Should create new auction", async function () {
    const { deploy, save } = deployments;
    const { deployer, seller } = await getNamedAccounts();

    console.log("test factory with seller:", seller);
    //为部署拍卖合约铸币
    const MockERC721 = await ethers.getContractFactory("MockERC721");
    const mockERC721 = await MockERC721.deploy();
    await mockERC721.waitForDeployment();
    const mockERC721Contract = await mockERC721.getAddress();
    await mockERC721.mint(seller, 2);
    console.log("seller 铸币完成");

    const duration = 86400;
    const startPrice = ethers.parseEther("0.1");
    const nftContract = mockERC721Contract;
    const nftToken = 2;
    const tokenAddress = ethers.ZeroAddress;

    console.log(11111111111);
    const tx = await factory
      .connect(seller)
      .createAuction(duration, startPrice, nftContract, nftToken, tokenAddress);
    console.log(22222222222);
    const d = await tx.wait();
    console.log("a:", d, ethers.isAddress(d));

    const allAuctions = await factory.getAuctions();
    expect(allAuctions).to.have.lengthOf(2);
  });

  describe("Auction Functionality", function () {});
});

const { expect } = require("chai");
const { ethers, deployments, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

describe("AuctionFactory with UUPS Upgrade", function () {
  let factory, auction, factoryProxy, auctionProxy;
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

  it("测试工厂加载拍卖合约", async function () {
    const storePath = path.resolve(
      __dirname,
      "../cache/store/proxyAuction.json"
    );
    let txt = JSON.parse(fs.readFileSync(storePath));
    expect(txt.implAddress).to.equal(auctionImplementation);
  });

  it("测试创建拍卖", async function () {
    const { deploy, save } = deployments;
    console.log("test factory with seller:", seller.address);
    //为部署拍卖合约铸币
    const MockERC721 = await ethers.getContractFactory("MockERC721");
    const mockERC721 = await MockERC721.deploy();
    await mockERC721.waitForDeployment();
    const mockERC721Contract = await mockERC721.getAddress();
    await mockERC721.mint(seller.address, 2);
    console.log("seller 铸币完成");

    const duration = 86400;
    const startPrice = ethers.parseEther("0.1");
    const nftContract = mockERC721Contract;
    const nftToken = 2;
    const tokenAddress = ethers.ZeroAddress;

    // 授权
    await mockERC721
      .connect(seller)
      .setApprovalForAll(factoryProxy.address, true);
    const tx = await factory.createAuction(
      duration,
      startPrice,
      nftContract,
      nftToken,
      tokenAddress
    );
    const d = await tx.wait();
    const allAuctions = await factory.getAuctions();
    expect(allAuctions).to.have.lengthOf(1);
  });


  it("测试购买者出价", async function () {
    // 购买者参与拍卖
    await expect(auction.connect(buyer).bid(0, ethers.ZeroAddress, { value: ethers.parseEther("0.01") })).to.be.revertedWith();
  });

});

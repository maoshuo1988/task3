// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

contract AuctionFactoryV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    address[] public auctions;
    mapping(address => bool) public isAuction;

    // 拍卖实现合约地址（用于创建新拍卖时的代理）
    address public auctionImplementation;
    event AuctionCreated(
        address indexed auction,
        uint256 duration,
        uint256 startPrice,
        address nftContract,
        uint256 nftToken,
        address tokenAddress
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function setAuctionImplementation(
        address _implementation
    ) public onlyOwner {
        console.log("_implementation:", _implementation);
        auctionImplementation = _implementation;
        console.log("auctionImplementation:", auctionImplementation);
    }

    function createAuction(
        uint256 _duration,
        uint256 _startPrice,
        address _nftContract,
        uint256 _nftToken,
        address _tokenAddress
    ) public returns (address) {
        require(auctionImplementation != address(0), "Implementation not set");
        bytes memory data = abi.encodeWithSignature(
            "initialize(uint256,uint256,address,uint256,address)",
            _duration,
            _startPrice,
            _nftContract,
            _nftToken,
            _tokenAddress
        );

        ERC1967Proxy proxy = new ERC1967Proxy(auctionImplementation, data);
        address auctionAddress = address(proxy);
        IERC721(_nftContract).approve(auctionAddress, _nftToken);
        auctions.push(auctionAddress);
        isAuction[auctionAddress] = true;

        emit AuctionCreated(
            auctionAddress,
            _duration,
            _startPrice,
            _nftContract,
            _nftToken,
            _tokenAddress
        );
        return auctionAddress;
    }

    function getAuctions() public view returns (address[] memory) {
        return auctions;
    }

    function getAuctionCount() public view returns (uint256) {
        return auctions.length;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}

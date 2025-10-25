
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract AuctionV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public duration;
    uint256 public startPrice;
    address public nftContract;
    uint256 public nftToken;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;
    bool public ended;
    address public tokenAddress;

    mapping(address => uint256) public pendingReturns;

    event AuctionStarted(uint256 duration, uint256 startPrice, address nftContract, uint256 nftToken, address tokenAddress);
    event NewHighestBid(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    AggregatorV3Interface internal ethUsdPriceFeed;

    mapping(address => AggregatorV3Interface) public priceFeeds;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        uint256 _duration,
        uint256 _startPrice,
        address _nftContract,
        uint256 _nftToken,
        address _tokenAddress
    ) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        console.log("_nftContract:", _nftContract);

        // IERC721(_nftContract).approve(address(this), _nftToken);
        
        duration = _duration;
        startPrice = _startPrice;
        nftContract = _nftContract;
        nftToken = _nftToken;
        tokenAddress = _tokenAddress;
        auctionEndTime = block.timestamp + _duration;
        
        emit AuctionStarted(_duration, _startPrice, _nftContract, _nftToken, _tokenAddress);
    }

    function bid(uint256 _amount, address _tokenAddress) public payable {
        //结束前校验
        require(block.timestamp <= auctionEndTime, "Auction already ended");
        uint payVal;
        //换算出价价值
        payVal = _tokenAddress == address(0)
            ? msg.value * uint(getChainlinkDataFeedLatestAnswer(address(0)))
            : uint(getChainlinkDataFeedLatestAnswer(_tokenAddress));
        //切换coin或者token
        _amount = _tokenAddress == address(0) ? _amount : msg.value;
        //换算起拍与最高出价
        uint256 startPriceVal = startPrice *
            uint(getChainlinkDataFeedLatestAnswer(_tokenAddress));
        uint256 highestBidVal = highestBid *
            uint(getChainlinkDataFeedLatestAnswer(_tokenAddress));

        require(
            payVal > startPriceVal && payVal > highestBidVal,
            "bid must be higher than the highest bid"
        );
        //授权合约
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        if (tokenAddress == address(0)) {
            payable(highestBidder).transfer(highestBid);
        } else {
            IERC20(tokenAddress).transfer(
                highestBidder,
                highestBid
            );
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        tokenAddress = _tokenAddress;
        emit NewHighestBid(msg.sender, msg.value);
    }


    function endAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "AuctionEnd has already been called");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // Transfer NFT to winner
        if (highestBidder != address(0)) {
            IERC721(nftContract).safeTransferFrom(address(this), highestBidder, nftToken);
        }
    }

    function setFeed(address feedAddress) public {
        ethUsdPriceFeed = AggregatorV3Interface(feedAddress);
    }

    function setPrice(address _tokenAddress, address _priceFeedAdddress) public {
        priceFeeds[_tokenAddress] = AggregatorV3Interface(_priceFeedAdddress);
    }

    function getChainlinkDataFeedLatestAnswer(
        address _tokenAddress
    ) public view returns (int) {
        AggregatorV3Interface priceFeed = priceFeeds[_tokenAddress];
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return answer;
    }

    function convertEthToUSD(
        uint256 ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = uint256(
            getChainlinkDataFeedLatestAnswer(address(0))
        );
        return (ethAmount * ethPrice) / (10 ** 8);
        // eth amount * eth price = eth val
    }
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

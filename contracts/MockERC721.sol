// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockERC721 is ERC721Enumerable, Ownable{
    string private _tokenURI;
    constructor () ERC721("tol","tl") Ownable(msg.sender){}

    function mint(address to,uint256 tokenId) external onlyOwner {
        _mint(to,tokenId);
    }

    function setTokenURI(string memory newTokenURI) external onlyOwner {
        _tokenURI = newTokenURI;
    }
}
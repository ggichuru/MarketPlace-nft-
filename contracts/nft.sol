// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    // Counters allow us keep track of token ids
    Counters.Counter private _tokenIds;

    address contractAddress;

    // Give the NFT market the ability to transact with tokens or change ownership

    // set up our address
    constructor(address marketplaceAddress) ERC721("GGRilizer", "GGR") {
        contractAddress = marketplaceAddress;
    }

    function mintToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);

        // takes id and url
        _setTokenURI(newItemId, tokenURI);

        // Give the market place the approval to transact b2n users.
        setApprovalForAll(contractAddress, true);

        // mint token and set it for sale
        return newItemId;
    }
}

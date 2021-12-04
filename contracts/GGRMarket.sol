// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // security agains tnx for multiple requests
import "hardhat/console.sol";

contract GGRMarket is ReentrancyGuard {
    using Counters for Counters.Counter;

    // number of items minting, number of tnx, tokens that haven't been sold, keep track of tokens total number

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;

    // Determine contract owner and charge listing fee
    address payable owner;

    uint256 listingPrice = 0.045 ether;

    constructor() {
        // Set the owner
        owner = payable(msg.sender);
    }

    struct MarketToken {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // TokenId return which marketToken - fetch which one it is

    mapping(uint256 => MarketToken) private idToMarketToken;

    // listen to events from frontend apps
    event MarketTokenMinted(
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 price,
        address indexed nftContract,
        address seller,
        address owner,
        bool sold
    );

    // get the listing price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /**
        @dev Functions to interact with our contract
        1. Create a market item to put it up for sale
        2. Create a market sale for buying and selling between parties.
     */

    function mintMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        // modifier to prevent reentry attack
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        _tokenIds.increment();
        uint256 itemId = _tokenIds.current();

        // Put it up for sale - bool - no owner
        idToMarketToken[itemId] = MarketToken(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        // transfer nft
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketTokenMinted(
            itemId,
            tokenId,
            price,
            nftContract,
            msg.sender,
            address(0),
            false
        );
    }

    // Conduct tnx and market sales
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketToken[itemId].price;
        uint256 tokenId = idToMarketToken[itemId].tokenId;

        require(
            msg.value == price,
            "Please submit the asking price in order to continue"
        );

        // Transfer amount to the seller
        idToMarketToken[itemId].seller.transfer(msg.value);

        // Transfet token from contract addr to the buyer
        IERC721(nftContract).transferFrom((address(this)), msg.sender, tokenId);
        idToMarketToken[itemId].owner = payable(msg.sender);
        idToMarketToken[itemId].sold = true;
        _tokensSold.increment();

        // Transfer price
        payable(owner).transfer(listingPrice);
    }

    // Fetch market items - minting, buying and selling || return number of unsold items
    function fetchMarketTokens() public view returns (MarketToken[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _tokensSold.current();
        uint256 currentIndex = 0;

        // Looping over number of items created -> [ if number hasn't been sold, populate the array ]
        MarketToken[] memory items = new MarketToken[](unsoldItemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
}

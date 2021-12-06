const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GGRMarket", function () {
  it("Should mint and trade NFTs", async function () {
    const Market = await ethers.getContractFactory('GGRMarket')
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    const NFT = await ethers.getContractFactory('NFT')
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    const acutionPrice = ethers.utils.parseUnits('20', 'ether')

    // Minting
    await nft.mintToken('https-t1')
    await nft.mintToken('https-t2')

    await market.makeMarketItem(nftContractAddress, 1, acutionPrice, { value: listingPrice })
    await market.makeMarketItem(nftContractAddress, 2, acutionPrice, { value: listingPrice })


    // Test for different addresse from different users
    const [_, buyerAddress] = await ethers.getSigners()

    // Create a market sale with market, id and price
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {
      value: acutionPrice
    })

    const items = await market.fetchMarketTokens()

    console.log('items', items)
  });
});

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftMarketplace__PriceMustBeAboveZero();
error NftMarketplace__NftNotApproved();
error NftMarketplace__AlreadyListed();
error NftMarketplace__NotOwner();

contract NftMarketplace {

    struct Listing {
        uint256 price;
        address seller;
    }
    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    // Nft Contract address -> Nft tokenID -> Listing
    mapping (address => mapping (uint256 => Listing)) private listings;

    modifier notListed (address nftAddress, uint256 tokenId, address owner) {
        Listing memory listing = listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert NftMarketplace__AlreadyListed();
        }
        _;
    }

    modifier isOwner (address nftAddress, uint256 tokenId, address spender) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NftMarketplace__NotOwner();
        }
        _;
    }

    /////////Main Functions/////////////

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external 
    notListed(nftAddress, tokenId, msg.sender)
    isOwner (nftAddress, tokenId, msg.sender) 
    {
        if (price <= 0) {
            revert NftMarketplace__PriceMustBeAboveZero();
        }

        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketplace__NftNotApproved();
        }

        listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);

    }

    function buyItem(address nftAddress, uint256 tokenId) external payable {

    }
}
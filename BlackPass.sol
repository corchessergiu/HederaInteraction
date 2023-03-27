// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "./ERC721AQueryable.sol";
import "./ERC721ABurnable.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Strings.sol";

contract BlackPass is ERC721A, ERC721AQueryable,ERC721ABurnable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    /** 
     * @dev A boolean that indicates whether the mint function is paused or not.
     */
    bool public pauseMint = true;

    /** 
     * @dev Prefix for tokens metadata URIs
     */
    string public baseURI;

    /** 
     * @dev Sufix for tokens metadata URIs
     */
    string public uriSuffix = '.json';

    /** 
     * @dev Allows the transfer of nfts only to these addresses
     */
    mapping(address => bool) public allowedStakingPlatform; 

    /** 
     * @dev Number of gold nfts owned by user
     */
    mapping(address => uint256) public goldAmount; 

    /** 
     * @dev Number of diamond nfts owned by user
     */
    mapping(address => uint256) public diamondAmount; 

    mapping(address => bool) public alreadyMintNFT;

     constructor(
        string memory uri
    )
     ERC721A("BlackPass", "BLKP") {
        baseURI = uri;
    }

    function setAmount(address userAddress, uint256 goldNumber, uint256 diamondNumber) external onlyOwner {
        require(goldNumber <= 222, "BLKP: gold max supply exceeded!");
        require(diamondNumber <= 500, "BLKP: diamond max supply exceeded!");
        goldAmount[userAddress] = goldNumber;
        diamondAmount[userAddress] = diamondNumber;
    }

    function mint() external nonReentrant {
        require(!pauseMint, "BLKP: Mint closed");
        require(goldAmount[msg.sender] > 0 || diamondAmount[msg.sender] > 0, "BLKP: you don't own any nft gold or diamond!");
        require(!alreadyMintNFT[msg.sender], "BLKP: user already minted an BKLP NFT!");
        alreadyMintNFT[msg.sender] = true;
        _safeMint(msg.sender, 1);
    }

    function setAllowedContract(address contractAddress, bool state) public onlyOwner{
        allowedStakingPlatform[contractAddress] = state;
    }

    /**
     * @dev Sets the uriSuffix for the ERC-721 token metadata.
     * @param _uriSuffix The new uriSuffix to be set.
     */
    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    /**
     * @dev Set the global pause state of the contract, only the contract owner can set the pause state
     * @param state Boolean state of the pause, true means that the contract is paused, false means that the contract is not paused
     */
    function setPauseMint(bool state) external onlyOwner{
        pauseMint = state;
    }

    /**
     * @dev Returns the current base URI.
     * @return The base URI of the contract.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
    * @dev This function sets the base URI of the NFT contract.
    * @param uri The new base URI of the NFT contract.
    * @notice Only the contract owner can call this function.
    */
    function setBasedURI(string memory uri) external onlyOwner{
        baseURI = uri;
    }

    /**
    * @dev Returns the starting token ID for the token.
    * @return uint256 The starting token ID for the token.
    */
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /**
     * @dev Returns the token URI for the given token ID. Throws if the token ID does not exist
     * @param _tokenId The token ID to retrieve the URI for
     * @notice Retrieve the URI for the given token ID
     * @return The token URI for the given token ID
     */
    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A,IERC721A) returns (string memory) {
        require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
            : '';
    }

    function setApprovalForAll(address operator, bool approved) public virtual override(ERC721A,IERC721A) {
        require(allowedStakingPlatform[operator],"BLKP: Invalid staking address");
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override(ERC721A,IERC721A) {
        require(allowedStakingPlatform[operator],"BLKP: Invalid staking address");
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override(ERC721A,IERC721A)  {
        require(allowedStakingPlatform[to] || allowedStakingPlatform[from], "BLKP: Invalid staking address");
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override(ERC721A,IERC721A) {
        require(allowedStakingPlatform[to] || allowedStakingPlatform[from], "BLKP: Invalid staking address");
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        payable 
        override(ERC721A,IERC721A)
    {
        require(allowedStakingPlatform[to] || allowedStakingPlatform[from], "BLKP: Invalid staking address");
        super.safeTransferFrom(from, to, tokenId, data);
    }

}
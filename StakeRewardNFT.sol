// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./ERC721A.sol";
import "./ERC721AQueryable.sol";
import "./ERC721ABurnable.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Strings.sol";

 /**
  * @title Deviants
  * @dev The contract allows users to mint:
  * For each Silver Mint Pass - Mint 2 crimson pass
  * For each Diamond Mint Pass- Mint 3 crimson pass
  * For each Gold Mint Pass- Mint 4 crimson pass
  * @dev The contract has 2 phases, Phase1 sale and Phase2.
  * @dev The contract uses a Merkle proof to validate that an address is whitelisted.
  * @dev The contract also has an owner who have the privilages to set the state of the contract and withdraw erc20 native tokens.
  */
contract StakeRewardNFT is ERC721A, ERC721AQueryable,ERC721ABurnable, Ownable, ReentrancyGuard{
    using Strings for uint256;

    bool public globalPause = true;

    /** 
     * @dev Prefix for tokens metadata URIs
     */
    string public baseURI;

    /** 
     * @dev Sufix for tokens metadata URIs
     */
    string public uriSuffix = '.json';

    mapping(address => bool) public allowedAddressToCallMint;

    mapping(uint256 => uint256) public tokenAllocation;

     /**
     * @dev Constructor function that sets the initial values for the contract's variables.
     * @param uri The metadata URI prefix.
     */
    constructor(
        string  memory uri
    ) ERC721A("Reward Staking for BlackPass", "RBLKP") {
        baseURI = uri;
    }

    function mint(address user, uint256 amount) external nonReentrant {
        require(!globalPause, "RBLKP: mint is close!");
        require(allowedAddressToCallMint[msg.sender], "RBLKP: not allowed address");
        tokenAllocation[ERC721A(address(this)).totalSupply() + 1] = amount;
        _safeMint(user, 1);
    } 

    function setAllowedContract(address contractAddress, bool state) public onlyOwner{
        allowedAddressToCallMint[contractAddress] = state;
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
     * @dev Set the global pause state of the contract, only the contract owner can set the pause state
     * @param state Boolean state of the pause, true means that the contract is paused, false means that the contract is not paused
     */
    function setGlobalPause(bool state) external onlyOwner{
        globalPause = state;
    }


    /**
     * @dev Sets the uriSuffix for the ERC-721 token metadata.
     * @param _uriSuffix The new uriSuffix to be set.
     */
    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
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
        
    /**
     * @dev Returns the current base URI.
     * @return The base URI of the contract.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }


}

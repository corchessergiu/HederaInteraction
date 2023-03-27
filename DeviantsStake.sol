// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC721Receiver.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Strings.sol";
import "./BlackPass.sol";
import "./StakeRewardNFT.sol";

contract DeviantsStake is IERC721Receiver, Ownable, ReentrancyGuard {

    /** 
    * @dev A boolean that indicates whether the contract is paused or not.
    */
    bool public pause = true;

    /** 
    * @dev penality tax which which is applied if the user withdraws his nft before reaching maturity.
    */
    uint256 public penalityTax = 100 ether;

    /** 
    * @dev BlackPass contract.
    */
    BlackPass public blackPass;

    /** 
    * @dev StakeRewardNFT contract.
    */
    StakeRewardNFT public stakeReward;

    /** 
    * @dev thirtyDaysPoolData keeps user data for the 30-day pool.
    */
    struct thirtyDaysPoolData { 
        uint256 startTime;
        uint256 releaseTime;
        uint256 tokenId;
        bool poolAlreadyUsed;
        bool currentPool;
    }

    /** 
    * @dev fourtyFiveDaysPoolData keeps user data for the 45-day pool.
    */
    struct fourtyFiveDaysPoolData { 
        uint256 startTime;
        uint256 releaseTime;
        uint256 tokenId;
        bool poolAlreadyUsed;
        bool currentPool;
    }

    /** 
    * @dev fourtyFiveDaysPoolData keeps user data for the 60-day pool.
    */
    struct sixtyDaysPoolData { 
        uint256 startTime;
        uint256 releaseTime;
        uint256 tokenId;
        bool poolAlreadyUsed;
        bool currentPool;
    }
    
    /**
    * @dev A mapping that stores data about a user's stake for 30 days.
    */
    mapping(address => thirtyDaysPoolData) public userThirtyDaysData;

    /**
    * @dev A mapping that stores data about a user's stake for 45 days.
    */
    mapping(address => fourtyFiveDaysPoolData) public userFortyFiveDaysData;

    /**
    * @dev A mapping that stores data about a user's stake for 60 days.
    */
    mapping(address => sixtyDaysPoolData) public userSixtyDaysData;

    /**
    * @dev Emits an event when an NFT is staked for 30 days.
    * @param user The address of the user who executed the stake function.
    * @param startTime The time at which the stake started.
    * @param releaseTime The time at which the stake ends.
    * @param tokenId The tokenid of the nft that was staked.
    */
    event ThirtyDaysStake(
        address indexed user,
        uint256 startTime,
        uint256 releaseTime,
        uint256 indexed tokenId
    );

    /**
    * @dev Emits an event when an NFT is staked for 45 days.
    * @param user The address of the user who executed the stake function.
    * @param startTime The time at which the stake started.
    * @param releaseTime The time at which the stake ends.
    * @param tokenId The tokenid of the nft that was staked.
    */
    event FourtyFiveDaysStake(
        address indexed user,
        uint256 startTime,
        uint256 releaseTime,
        uint256 indexed tokenId
    );

    /**
    * @dev Emits an event when an NFT is staked for 60 days.
    * @param user The address of the user who executed the stake function.
    * @param startTime The time at which the stake started.
    * @param releaseTime The time at which the stake ends.
    * @param tokenId The tokenid of the nft that was staked.
    */
    event SixtyDayStake(
        address indexed user,
        uint256 startTime,
        uint256 releaseTime,
        uint256 indexed tokenId
    );

    /**
    * @dev Emits an event when an NFT is staked for 60 days.
    * @param user The address of the user who executed the stake function.
    * @param reward The number of tokens received.
    * @param tokenId The tokenid of the nft that was unstaked.
    */
    event Claim(
        address indexed user,
        uint256 reward,
        uint256 indexed tokenId
    );

     constructor(
        address _blackPass,
        address _stakeReward){
        blackPass = BlackPass(_blackPass);
        stakeReward = StakeRewardNFT(_stakeReward);
    }

    function thirtyDaysPool(uint256 tokenId) external nonReentrant {
        require(!pause, "RCARD: you can't stake yet!");
        require(blackPass.balanceOf(msg.sender) == 1, "RCARD: you don't have a blackpass!");
        require(!userThirtyDaysData[msg.sender].poolAlreadyUsed, "RCARD: you have already used this pool!");
        uint256 totalNumberOfDecreaseDays = blackPass.diamondAmount(msg.sender) + blackPass.goldAmount(msg.sender) * 2;
        
        userThirtyDaysData[msg.sender].startTime = block.timestamp;
        userThirtyDaysData[msg.sender].poolAlreadyUsed = true;
        userThirtyDaysData[msg.sender].tokenId = tokenId;
        userThirtyDaysData[msg.sender].currentPool = true;
        blackPass.safeTransferFrom(msg.sender, address(this), tokenId);
        if(totalNumberOfDecreaseDays >= 30){
            userThirtyDaysData[msg.sender].releaseTime = block.timestamp;
        } else {
            uint256 daysLeft = 30 - totalNumberOfDecreaseDays;
            userThirtyDaysData[msg.sender].releaseTime = block.timestamp + daysLeft * 1 days;
        }

        emit ThirtyDaysStake(msg.sender, block.timestamp, userThirtyDaysData[msg.sender].releaseTime, tokenId);
    }

    function fortyFiveDaysPool(uint256 tokenId) external nonReentrant {
        require(!pause, "RCARD: you can't stake yet!");
        require(blackPass.balanceOf(msg.sender) == 1, "RCARD: you don't have a blackpass!");
        require(!userFortyFiveDaysData[msg.sender].poolAlreadyUsed, "RCARD: you have already used this pool!");
        uint256 totalNumberOfDecreaseDays = blackPass.diamondAmount(msg.sender) + blackPass.goldAmount(msg.sender) * 2;
        
        userFortyFiveDaysData[msg.sender].startTime = block.timestamp;
        userFortyFiveDaysData[msg.sender].poolAlreadyUsed = true;
        userFortyFiveDaysData[msg.sender].tokenId = tokenId;
        userFortyFiveDaysData[msg.sender].currentPool = true;
        blackPass.safeTransferFrom(msg.sender, address(this), tokenId);

        if(totalNumberOfDecreaseDays >= 45){
            userFortyFiveDaysData[msg.sender].releaseTime = block.timestamp;
        } else {
            uint256 daysLeft = 45 - totalNumberOfDecreaseDays;
            userFortyFiveDaysData[msg.sender].releaseTime = block.timestamp + daysLeft * 1 days;
        }

        emit FourtyFiveDaysStake(msg.sender, block.timestamp, userFortyFiveDaysData[msg.sender].releaseTime, tokenId);
    }

    function sixtyDaysPool(uint256 tokenId) external nonReentrant {
        require(!pause, "RCARD: you can't stake yet!");
        require(blackPass.balanceOf(msg.sender) == 1, "RCARD: you don't have a blackpass!");
        require(!userSixtyDaysData[msg.sender].poolAlreadyUsed, "RCARD: you have already used this pool!");
        uint256 totalNumberOfDecreaseDays = blackPass.diamondAmount(msg.sender) + blackPass.goldAmount(msg.sender) * 2;
        
        userSixtyDaysData[msg.sender].startTime = block.timestamp;
        userSixtyDaysData[msg.sender].poolAlreadyUsed = true;
        userSixtyDaysData[msg.sender].tokenId = tokenId;
        userSixtyDaysData[msg.sender].currentPool = true;
        blackPass.safeTransferFrom(msg.sender, address(this), tokenId);

        if(totalNumberOfDecreaseDays >= 60){
            userSixtyDaysData[msg.sender].releaseTime = block.timestamp;
        } else {
            uint256 daysLeft = 60 - totalNumberOfDecreaseDays;
            userSixtyDaysData[msg.sender].releaseTime = block.timestamp + daysLeft  * 1 days;
        }

        emit SixtyDayStake(msg.sender, block.timestamp, userFortyFiveDaysData[msg.sender].releaseTime, tokenId);
    }

    function claim() external payable nonReentrant {
        require(!pause, "RCARD: claim is close!");
        require(userThirtyDaysData[msg.sender].currentPool == true ||  userFortyFiveDaysData[msg.sender].currentPool == true ||   userSixtyDaysData[msg.sender].currentPool == true, "RCARD: you don't have a stake at the moment");
        
        if(userThirtyDaysData[msg.sender].currentPool == true){
            if(block.timestamp >= userThirtyDaysData[msg.sender].releaseTime){
                userThirtyDaysData[msg.sender].currentPool = false;
                stakeReward.mint(msg.sender, 10000);
                blackPass.safeTransferFrom(address(this), msg.sender, userThirtyDaysData[msg.sender].tokenId);
                emit Claim(msg.sender, 10000, userThirtyDaysData[msg.sender].tokenId);
            } else {
                require(msg.value == penalityTax,"RCARD: user must send the exact penality amount");
                userThirtyDaysData[msg.sender].currentPool = false;
                blackPass.safeTransferFrom(address(this), msg.sender, userThirtyDaysData[msg.sender].tokenId);
                emit Claim(msg.sender, 0, userThirtyDaysData[msg.sender].tokenId);
            }
        }

        if(userFortyFiveDaysData[msg.sender].currentPool == true){
            if(block.timestamp >= userFortyFiveDaysData[msg.sender].releaseTime){
                userFortyFiveDaysData[msg.sender].currentPool = false;
                stakeReward.mint(msg.sender, 15000);
                blackPass.safeTransferFrom(address(this), msg.sender,  userFortyFiveDaysData[msg.sender].tokenId);
                emit Claim(msg.sender, 15000, userFortyFiveDaysData[msg.sender].tokenId);
            } else {
                require(msg.value == penalityTax,"RCARD: user must send the exact penality amount");
                userFortyFiveDaysData[msg.sender].currentPool = false;
                blackPass.safeTransferFrom(address(this), msg.sender, userFortyFiveDaysData[msg.sender].tokenId);
                emit Claim(msg.sender, 0, userFortyFiveDaysData[msg.sender].tokenId);
            }
        }

        if(userSixtyDaysData[msg.sender].currentPool == true){
            if(block.timestamp >= userSixtyDaysData[msg.sender].releaseTime){
                userSixtyDaysData[msg.sender].currentPool = false;
                stakeReward.mint(msg.sender, 20000);
                blackPass.safeTransferFrom(address(this), msg.sender,  userSixtyDaysData[msg.sender].tokenId);
                emit Claim(msg.sender, 20000, userSixtyDaysData[msg.sender].tokenId);
            } else {
                require(msg.value == penalityTax,"RCARD: user must send the exact penality amount");
                userSixtyDaysData[msg.sender].currentPool = false;
                blackPass.safeTransferFrom(address(this), msg.sender, userSixtyDaysData[msg.sender].tokenId);
                emit Claim(msg.sender, 0, userSixtyDaysData[msg.sender].tokenId);
            }
        }

    }

    /**
    * @dev Set the global pause state of the contract, only the contract owner can set the pause state
    * @param state Boolean state of the pause, true means that the contract is paused, false means that the contract is not paused
    */
    function setPause(bool state) external onlyOwner{
        pause = state;
    }

    /**
    * @dev Set the penality tax
    * @param _penalityTax new penality tax value
    */
    function setPenalityTax(uint256 _penalityTax) external onlyOwner{
        penalityTax = _penalityTax;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
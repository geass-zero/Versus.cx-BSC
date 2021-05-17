pragma solidity ^0.6.6;

import "./BEP20.sol";

contract Versus is BEP20 {
    using SafeERC20 for IBEP20;
    using SafeMath for uint256;

    address public owner;
    
    struct userStruct {
        uint256 amountStaked;
        uint256 blockChecked;
        uint128 winStreak;
        uint256 totalVolume;
        uint32 currentLevel;
        uint32[] NFTsUnlocked;
    }
    mapping(address => userStruct) public userData; 

    uint32[] public levelStreakRequirements;

    uint256 public freeBNBReturned;
    uint256 public predictionFees;

    mapping(address => bool) whitelistedContracts;
    
    constructor() public payable BEP20("Versus.cx", "Versus"){
        owner = msg.sender;
    }
    
    function setLevels(uint32[] memory requirements) public {
        require(msg.sender == owner);
        levelStreakRequirements = requirements;
    }
    
    function returnFreeBNB() public payable {
        freeBNBReturned = freeBNBReturned.add(msg.value);
    }

    function returnPredictionFees() public payable {
        predictionFees = predictionFees.add(msg.value);
    }

    function useFees() public {

    }

    function updateStats(address user, uint256 volume) public {
        require(whitelistedContracts[msg.sender]);
        userData[user].totalVolume = userData[user].totalVolume.add(1);
        //increase total Versus volume
    }

    function updateUserWins(address _user, uint32[] wins) public {
        require(whitelistedContracts[msg.sender]);
        
        for (uint i; i < wins.length; i++) {
            userData[_user].winStreak = userData[_user].winStreak.add(wins[i]);
            if (levelStreakRequirements[userData[_user].userLevel] < userData[_user].winStreak) {
                userData[_user].winStreak = userData[_user].winStreak.sub(levelStreakRequirements[userData[_user].userLevel]);
                userData[_user].userLevel = userData[_user].userLevel.add(1);
                userData[_user].NFTsUnlocked.push(userData[_user].userLevel);

                //need to deal with streak rollover
            }
        }
    }

    function mintNFT(address _user) public {
        
    
    }

    function whiteListContract(address _contract, bool _direction) public {
        require(msg.sender == owner);
        whitelistedContracts[_contract] = _direction;
    }
    
}

interface NyanDev {
    
}

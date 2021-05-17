pragma solidity ^0.6.6;

import "./BEP20.sol";

contract TokenBattle is BEP20{
    
    using SafeERC20 for IBEP20;
    using SafeMath for uint256;

    address[] public markets;
    address public owner;
    address public versusToken;

    struct marketStruct {
        uint256 round;
        address[] tokens;
        uint256[] startPrice;
        uint256[] BNBWaged;
        uint256 roundStart;
        
        address[] nextTokens;
        uint256[] nextBNBWaged;
    }
    mapping(address => marketStruct) public battleData; 

    struct marketHistory {
        address[] tokens;
        address winningToken;
        uint256[] startPrices;
        uint256[] endPrices;
        uint256[] BNBWaged;
    }
    mapping(uint256 => marketHistory) public battleHistory;

    address[] public futureTokenList;

    struct userStruct {
        address[] tokenHistory;
        uint256[] round;
        uint256[] roundStart;
        uint256[] roundEnd;
        uint256[] BNBAmount;
        uint256[] predictionWinnings;
        uint256 lastCheckedIndex;

    }
    mapping(address => userStruct) public userHistory;

    mapping(address => bool) public isAdmin;

    constructor() public {
        owner = msg.sender;
    }

    //add initial tokens(max 10)
    function initialiseBattle(address[] memory tokens) public {
        require(tokens.length <= 10);
        futureTokenList = tokens;
        battleData[address(this)].round = 1;
        battleData[address(this)].tokens = tokens;
        battleData[address(this)].roundStart = block.number;
        for (uint32 i; i < tokens.length; i++) {
            battleData[address(this)].startPrice[i] = 0;//set start price
            battleData[address(this)].BNBWaged.push(0);

            battleData[address(this)].nextTokens.push(tokens[i]);
            battleData[address(this)].nextBNBWaged.push(0);

        }
    }


    //change one token, based on index
    function changeNextToken(uint32 index, address newToken) public {
        require(isAdmin[msg.sender]);
        futureTokenList[index] = newToken;
    }

    //expire round
    function expireRound() public {
        require(battleData[address(this)].roundStart.add(10) < block.number); //determine blocks
        
    }

    //enter a round(free prediction usable)


    //claim wins


}

interface VersusToken {
    function hasFreePrediction(address user) external returns(uint256);
    function returnPredictionFees() external;
    function returnFreeBNB() external;
    function updateStats(address user, uint256 volume) external;
    function updateUserWins(address _user, bool _isWin) external;
}

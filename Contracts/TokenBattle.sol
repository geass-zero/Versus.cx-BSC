pragma solidity ^0.6.6;

import "./BEP20.sol";
import "./CakeInterface.sol";

contract TokenBattle is BEP20{
    
    using SafeERC20 for IBEP20;
    using SafeMath for uint256;

    address[] public markets;
    address public owner;
    address public versusToken;
    address public wBNB;

    struct marketStruct {
        uint256 round;
        address[] tokens;
        uint256[] startBNB;
        uint256[] BNBWaged;
        uint256 roundStart;
        
        address[] nextTokens;
        uint256[] nextBNBWaged;
    }
    mapping(address => marketStruct) public battleData; 

    struct marketHistory {
        address[] tokens;
        address winningToken;
        uint256[] startBNB;
        uint256[] endBNB;
        uint256[] roundStart;
        uint256[] roundEnd;
        uint256[] BNBWaged;
    }
    mapping(uint256 => marketHistory) public battleHistory;

    address[] public futureTokenList;

    struct userStruct {
        address[] tokenHistory;
        uint256[] round;
        uint256[] BNBAmount;
        uint256[] predictionWinnings;
        bool[] isFreePrediction;
        uint256 lastCheckedIndex;

    }
    mapping(address => userStruct) public userHistory;

    mapping(address => bool) public isAdmin;

    address public pancakeSwapV2;

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
            battleData[address(this)].startBNB[i] = IBEP20(wBNB).balanceOf(tokens[i]);//set start BNB
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
        require(battleData[address(this)].roundStart.add(1000) < block.number); //determine blocks
        address winningToken;
        uint256 highestBNBChange;
        address leastLossToken;
        uint256 leastLoss;
        for (uint i; i < tokens.length; i++) {
            uint256 startBNB = battleData[address(this)].tokens[i]; 
            uint256 tokenBNB = IBEP20(wBNB).balanceOf(tokens[i]);

            if (tokenBNB < startBNB) {
                if (leastLoss == 0) {
                    leastLoss = startBNB.sub(tokenBNB);
                    leastLossToken = token[i];
                } else if (startBNB.sub(tokenBNB) < leastLoss) {
                    leastLoss = startBNB.sub(tokenBNB);
                    leastLossToken = token[i];
                }
            }

            if (tokenBNB > startBNB) {
                if (highestBNBChange == 0) {
                    highestBNBChange = tokenBNB.sub(startBNB);
                    winningToken = tokens[i];
                } else if (highestBNBChange < tokenBNB.sub(startBNB)) {
                    highestBNBChange = tokenBNB.sub(startBNB);
                    winningToken = tokens[i];
                }
            }

            //check if winningToken exists
            //or for leastLossToken
            //save info in marketHistory
            //update tokens for next round


        }
    }

    //enter a round(free prediction usable)
    function enterBattle(address _token, uint tokenIndex, bool isFreePrediction) payable public {
        require(tokens[tokenIndex] == _token);

        //check if user has placed prediction in next round
        uint256[] memory userRound = userHistory[msg.sender].round;
        require(userRound[userRound.length-1] < battleData[address(this)].round+1);

        if (isFreePrediction) {
            require(msg.value == 0);
            //check if user has staked long enough for a free prediction
            msg.value = VersusToken(versusToken).hasFreePrediction(msg.sender);
        }

        require (msg.value > 0);
        uint256 BNBAmount = msg.value;
        //send 3% of value to token contract as fees
        uint256 fees = BNBAmount.mul(3).div(100);
        VersusToken(versusToken).returnPredictionFees(){value: fees};

        battleData[address(this)].BNBWaged[tokenIndex] = battleData[address(this)].BNBWaged[tokenIndex].add(msg.value);
        userHistory[msg.sender].tokenHistory.push(_token);
        userHistory[msg.sender].round.push(battleData[address(this)].round+1);
        userHistory[msg.sender].BNBAmount.push(msg.value);

    }

    //claim wins
    function claimWins() public {
        for (uint32 i = userHistory[msg.sender].lastCheckedIndex+1; i < userHistory[msg.sender].round.length; i++) {
            //use BNB waged to determine user payout, if winner, else 0
            //if winner, check if prediction was free
            //if winner, update user wins

        }
        //update the lastCheckedIndex
    }

}

interface VersusToken {
    function hasFreePrediction(address user) external returns(uint256);
    function returnPredictionFees() external;
    function returnFreeBNB() external;
    function updateStats(address user, uint256 volume) external;
    function updateUserWins(address _user, bool _isWin) external;
}

pragma solidity ^0.6.6;

import "./BEP20.sol";

contract SpotBattle is BEP20{
    
    using SafeERC20 for IBEP20;
    using SafeMath for uint256;

    address[] public markets;
    address public owner;
    address public versusToken;

    struct marketStruct {
        uint256 round;
        uint256 targetPrice;
        uint256 longBNB;
        uint256 shortBNB;
        uint256 roundEnd;
        address[] currentEntrants;
        uint256 nextRoundLong;
        uint256 nextRoundShort;
        address[] nextEntrants;
        uint256[] targetHistory;
        uint256[] longHistory;
        uint256[] shortHistory;
        uint256[] closingHistory;
    }
    mapping(address => marketStruct) public marketData; 

    struct userStruct {
        address[] tokenHistory;
        uint256[] round;
        uint256[] BNBAmount;
        bool[] isLonging;
        bool[] isFreePrediction;
        bool[] winClaimed;
        uint256[] predictionWinnings;
        uint256 lastCheckedIndex;

    }
    mapping(address => userStruct) public userHistory;


    constructor() public {
        owner = msg.sender;
    }
    
    function addMarket(address token) public {
        markets.push(token);
        marketData[token].round = 1;
        marketData[token].targetPrice = 0; // get price from Link
        marketData[token].roundEnd = 0;//block.number + 5 mins in blocks

        marketData[token].targetHistory.push(marketData[token].targetPrice);

    }

    function nextRoundPrediction(address token, uint32 index, bool isLonging, bool freePrediction) public payable {
        require(markets[index] == token);
        //check if user has placed prediction in market
        bool hasPosition;
        for (uint256 i; i < marketData[token].nextEntrants.length; i++) {
            if (marketData[token].nextEntrants[i] == msg.sender) {
                hasPosition = true;
            }
        }
        require(!hasPosition);
        
        if (freePrediction) {
            require(msg.value == 0);
            //check if user has staked long enough for a free prediction
            msg.value = VersusToken(versusToken).hasFreePrediction(msg.sender);
        }
        require (msg.value > 0);
        uint256 BNBAmount = msg.value;
        //send 3% of value to token contract as fees
        uint256 fees = BNBAmount.mul(3).div(100);
        VersusToken(versusToken).returnPredictionFees(){value: fees};

        userHistory[msg.sender].tokenHistory.push(token);
        userHistory[msg.sender].round.push(marketData[token].round + 1);
        userHistory[msg.sender].BNBAmount.push(BNBAmount.sub(fees));
        userHistory[msg.sender].isLonging.push(isLonging);
        userHistory[msg.sender].winClaimed.push(false);
        userHistory[msg.sender].isFreePrediction.push(freePrediction);
        marketData[token].nextEntrants.push(msg.sender);

        VersusToken(versusToken).updateStats(msg.sender, BNBAmount.sub(fees));
    }

    function expireRound(address token, uint32 index) public {
        require(markets[index] == token);
        require(block.number >= marketData[token].roundEnd);
        marketData[token].longHistory.push(marketData[msg.sender].longBNB);
        marketData[token].shortHistory.push(marketData[msg.sender].shortBNB);
        uint256 closingPrice; //get current closing price
        marketData[token].closingHistory.push(closingPrice);

        marketData[token].longBNB = marketData[msg.sender].nextRoundLong;
        marketData[token].nextRoundLong = 0;
        marketData[token].shortBNB = marketData[msg.sender].nextRoundShort;
        marketData[token].nextRoundShort = 0;
        marketData[token].currentEntrants = marketData[token].nextEntrants;
        marketData[token].nextEntrants = [];

        marketData[token].round = marketData[token].round + 1;

        //reward function caller

    }

    function getUserMarketHistory(address user) public view returns(address[],uint256[],uint256[],bool[],bool[]) {
        return(
            userHistory[user].tokenHistory,
            userHistory[user].round,
            userHistory[user].BNBAmount,
            userHistory[user].isLonging,
            userHistory[user].winClaimed
        );
    }

    function claim() public {
        uint32[] winStreak;
        uint32 winIndex;
        bool previousWon;


        for (uint i = userHistory[msg.sender].lastCheckedIndex; i < userHistory[msg.sender].tokenHistory.length; i++) {
            bool roundWon;
            (roundWon) = claimWinnings(userHistory[msg.sender].round[i], msg.sender, userHistory[msg.sender].tokenHistory[i], i);

        }
        userHistory[msg.sender].lastCheckedIndex = userHistory[msg.sender].tokenHistory.length-1;
        VersusToken(versusToken).updateUserWins(msg.sender, winStreak);
    }

    function claimWinnings(
            uint256 round, 
            address user, 
            address token, 
            uint256 userIndex) internal returns(bool) {

        bool longWon = marketData[token].targetHistory[round-1] > marketData[token].closingHistory[round-1];
        
        if (userHistory[user].isLonging[userIndex] != longWon) {
            return false;
        }
        // if (userHistory[user].winClaimed[userIndex]) {
        //     return;
        // }

        uint256 BNBUsed = userHistory[user].BNBAmount[userIndex];
        uint256 percentageOwned;
        if (longWon) {
            percentageOwned = BNBUsed.mul(100).div(marketData[token].longHistory[round-1]);
        } else {
            percentageOwned = BNBUsed.mul(100).div(marketData[token].shortHistory[round-1]);
        }

        uint256 winnings;
        if (longWon) {
            winnings = marketData[token].longHistory[round-1].mul(percentageOwned).div(100);
        } else {
            winnings = marketData[token].shortHistory[round-1].mul(percentageOwned).div(100);
        }

        //send winnings to user after free prediction check and fees
        if (userHistory[user].isFreePrediction[userIndex]) {
            //send 90% to token contract
            VersusToken(versusToken).returnFreeBNB(){value: winnings.mul(90).div(100)};
            //reduce winnings by 90%
            winnings = winnings.sub(winnings.mul(90).div(100));
        }
        msg.sender.call{value: winnings}("");
        userHistory[user].winClaimed[userIndex] = true;

        //send user Versus as reward, if not free prediction, how much though?

        return true;
    }
    

    
}

interface VersusToken {
    function hasFreePrediction(address user) external returns(uint256);
    function returnPredictionFees() external;
    function returnFreeBNB() external;
    function updateStats(address user, uint256 volume) external;
    function updateUserWins(address _user, bool _isWin) external;
}
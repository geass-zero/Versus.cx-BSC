pragma solidity ^0.6.6;

import "./BEP20.sol";

contract VersusStats is BEP20 {
    
    using SafeERC20 for IBEP20;
    using SafeMath for uint256;

    address public owner;
    address public versusToken;

    uint256 public totalBNBVolume;

    address[] public topMonthly;
    uint256[] public monthlyVolume;

    address[] public topAllTime;
    uint256[] public topAllTimeVolume;

    constructor() public {
        owner = msg.sender;
    }
    
    
    function getStats() public view returns(uint256, address[] memory, uint256[] memory, address[] memory, uint256[] memory) {
        
    }

    function adjustMontlyLeaders(address user, uint256 volume) public {
        //require call come from Nyan token
        //if (monthlyVolumeLeaders[monthlyVolumeLeaders.length-1].volume >= volume) return false;

        bool volumePlaced;
        for (uint256 i; i < topMonthly.length; i++) {
            require(!volumePlaced);
            if (volume > monthlyVolume[i]) {
                address tempUser;
                uint256 tempVolume;

                tempUser = topMonthly[i];
                tempVolume = monthlyVolume[i];

                topMonthly[i] = user;
                monthlyVolume[i] = volume;
                volumePlaced = true;

                //shift other users down
                for (uint j = i+1; j < topMonthly.length; j++) {
                    
                }
            }


        }

        
    }

    function adjustAllTimeLeaders(address user, uint256 volume) public {
        //require call come from Nyan token
        
    }
    
}
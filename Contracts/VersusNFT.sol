pragma solidity ^0.6.0;

import "./BEP721.sol";
    
contract VersusNFT is BEP721 {
    using SafeMath for uint256;
    address public owner;
    
    uint256 _tokenId;
    
    struct details {
        uint32 NFTLevel;
        uint112 bonus;
        bool isStaked;
    }
    mapping(uint256 => details) nftDetails; 

    constructor() public payable BEP721("Versus Badge", "VersusNFT") {
        owner = msg.sender;

    }


    function setOwner(address _owner) public _onlyOwner delegatedOnly {
        owner = _owner;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        //use tokenId to determine NFT level
        uint256 tokenLevel = nftDetails[tokenId].NFTLevel;
        return super.tokenURI(tokenLevel);
    }
    
    /** @notice Creates a new Versus NFT.
      * @param _claimer Address of the claiming user.
      * @param _level Name of the NFT tier.
      */
    function createNFT(address _claimer, uint256 _level) public delegatedOnly returns(bool) {
        require(msg.sender == versusToken);
        uint256 newItemId = _tokenIds.add(1);
        _tokenIds = _tokenIds.add(1);
        _mint(_claimer, newItemId);
        nftDetails[newItemId].originalOwner = _claimer;
        nftDetails[newItemId].level = _level;
        
        return newItemId;
    }
    

    
    function getNFTDetails(uint256 id) public view delegatedOnly returns(address, string memory, uint112, bool) {
        return(nftDetails[id].originalOwner, nftDetails[id].tier, nftDetails[id].bonus, nftDetails[id].isStaked);
    }
    
    
}
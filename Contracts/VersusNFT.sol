pragma solidity ^0.6.0;

import "./BEP721.sol";
    
contract VersusNFT is BEP721 {
    using SafeMath for uint256;
    address public owner;
    
    uint256 _tokenIds;
    
    struct details {
        address originalOwner;
        string tier;
        uint112 bonus;
        bool isStaked;
    }
    mapping(uint256 => details) nftDetails; 

    constructor() public payable BEP721("Versus Badge", "VersusNFT") {

    }
    
    function NFTConstructor() public {
        require(!initialized);
        owner = msg.sender;
        constructor1("Versus Bagde", "VersusNFT");
        initialize();
    }

    function setOwner(address _owner) public _onlyOwner delegatedOnly {
        owner = _owner;
    }
    
    /** @notice Creates a new Versus NFT.
      * @param _claimer Address of the claiming user.
      * @param _tier Name of the NFT tier.
      */
    function createNFT(address _claimer, string memory _tier) public delegatedOnly returns(uint256) {
        uint256 newItemId = _tokenIds.add(1);
        _tokenIds = _tokenIds.add(1);
        _mint(_claimer, newItemId);
        nftDetails[newItemId].originalOwner = _claimer;
        nftDetails[newItemId].tier = _tier;
        if (keccak256(bytes(_tier)) == "COMMON") {
            nftDetails[newItemId].bonus = 1;
            _setTokenURI(newItemId, "https://ipfs.io/ipfs/QmQLNaJ6mW8u63j2GzXujffMtGtTSwBZQFUoP2P5BmjZ2b");
        }
        
        return newItemId;
    }
    

    
    function getNFTDetails(uint256 id) public view delegatedOnly returns(address, string memory, uint112, bool) {
        return(nftDetails[id].originalOwner, nftDetails[id].tier, nftDetails[id].bonus, nftDetails[id].isStaked);
    }
    
    
}
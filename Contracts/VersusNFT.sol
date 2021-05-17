pragma solidity ^0.6.0;

import "./BEP721.sol";

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract LibraryLockDataLayout {
  bool public initialized = false;
}

contract LibraryLock is LibraryLockDataLayout {
    // Ensures no one can manipulate the Logic Contract once it is deployed.
    // PARITY WALLET HACK PREVENTION

    modifier delegatedOnly() {
        require(initialized == true, "The library is locked. No direct 'call' is allowed.");
        _;
    }
    function initialize() internal {
        initialized = true;
    }
}

interface CatnipV2 {
    function miningNFTStaked(address, uint256) external;
    function miningNFTUnstaked(address) external;
}

interface DNyanV2 {
    function miningNFTStaked(address, uint256) external;
    function miningNFTUnstaked(address) external;
}

contract BEP721DataLayout is LibraryLock {
    address public owner;
    address public nyanV2;
    address public catnipV2;
    address public dNyanV2;
    
    uint256 _tokenIds;
    
    struct details {
        address originalOwner;
        string tier;
        uint112 bonus;
        bool isStaked;
    }
    mapping(uint256 => details) nftDetails; 
}
    
contract NyanNFT is ERC721, ERC721DataLayout, Proxiable {
    using SafeMath for uint256;

    modifier _onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier _onlyNyanV2() {
        require(msg.sender == nyanV2);
        _;
    }
    

    constructor() public payable ERC721("NyanNFT", "NYANKO") {

    }
    
    function NFTConstructor(address _nyanV2, address _catnipV2, address _dNyanV2) public {
        require(!initialized);
        owner = msg.sender;
        nyanV2 = _nyanV2;
        catnipV2 = _catnipV2;
        dNyanV2 = _dNyanV2;
        constructor1("NyanNFT", "NYANKO");
        initialize();
    }

    function setOwner(address _owner) public _onlyOwner delegatedOnly {
        owner = _owner;
    }
    
    /** @notice Creates a new Nyan NFT.
      * @param _claimer Address of the claiming user.
      * @param _tier Name of the NFT tier.
      */
    function createNFT(address _claimer, string memory _tier) public _onlyNyanV2 delegatedOnly returns(uint256) {
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
    
    //stake NFT
    function stakeNFT(uint256 _id) public delegatedOnly {
        require(ownerOf(_id) == msg.sender, "You do not own this token");
        CatnipV2(catnipV2).miningNFTStaked(msg.sender, nftDetails[_id].bonus);
        DNyanV2(dNyanV2).miningNFTStaked(msg.sender, nftDetails[_id].bonus);
        nftDetails[_id].isStaked = true;
    }
    
    //unstake NFT
    function unstakeNFT(uint256 _id) public delegatedOnly {
        require(ownerOf(_id) == msg.sender, "You do not own this token");
        CatnipV2(catnipV2).miningNFTUnstaked(msg.sender);
        DNyanV2(dNyanV2).miningNFTUnstaked(msg.sender);
        nftDetails[_id].isStaked = true;
    }
    
    function getNFTDetails(uint256 id) public view delegatedOnly returns(address, string memory, uint112, bool) {
        return(nftDetails[id].originalOwner, nftDetails[id].tier, nftDetails[id].bonus, nftDetails[id].isStaked);
    }
    
    function updateCode(address newCode) public _onlyOwner delegatedOnly  {
        updateCodeAddress(newCode);
    }

    function setNyanV2(address _addr) public _onlyOwner delegatedOnly {
        nyanV2 = _addr;
    }

    function setCatnipV2(address _addr) public _onlyOwner delegatedOnly {
        catnipV2 = _addr;
    }

    function setDNyanV2(address _addr) public _onlyOwner delegatedOnly {
        dNyanV2 = _addr;
    }
    
    
}
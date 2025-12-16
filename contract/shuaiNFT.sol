
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ShuaiNFT is ERC721 {
    uint256 public _nextTokenId;
    uint256 public _maxSupply;
    string public _baseTokenURI;
    address public owner;
    
    event NFTMinted(address indexed to, uint256 indexed tokenId);
    
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_,
        uint maxSupply_
    ) ERC721(name_, symbol_) {
        owner = msg.sender;
        _baseTokenURI = baseTokenURI_;
        _maxSupply = maxSupply_;
        _nextTokenId = 1;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    // 设置最大mint数量
    function setMaxSupply(uint maxSupply) public onlyOwner {
        _maxSupply = maxSupply;
    }

    // 设置nextTokenId
    function setNextTokenId(uint nextTokenId) public onlyOwner {
        _nextTokenId = nextTokenId;
    }
    
    // 设置基础 URI
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    // 铸造 NFT（仅所有者）
    function mint(address to) public onlyOwner returns (uint256) {
        require(_nextTokenId <= _maxSupply, "Max supply reached");
        
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        super._safeMint(to, tokenId);
        
        emit NFTMinted(to, tokenId);
        return tokenId;
    }
}

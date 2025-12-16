
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

contract nftBank is IERC777Recipient {

    IERC1820Registry private constant _ERC1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH =
        keccak256("ERC777TokensRecipient");

    IERC721 public _nft;
    IERC777 public _token;

    constructor(address nftAdress_, address tokenAddress_){
        _nft = IERC721(nftAdress_);
        _token = IERC777(tokenAddress_);

        _ERC1820.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    // 记录挂单
    mapping(uint tokenId => uint price) public orderList;
    // 记录订单状态 1:挂单 2:已出售
    mapping(uint tokenId => uint state) public orderState;

    // 事件
    event SellNFT(address user, uint tokenId, uint price);
    event BuyNFT(address user, uint tokenId, uint price);

    // 挂单
    function list(uint tokenId, uint price) public {
        address sender = msg.sender;
        address owner = _nft.ownerOf(tokenId);
        require(sender == _nft.ownerOf(tokenId) 
        || sender == _nft.getApproved(tokenId) 
        || _nft.isApprovedForAll(owner, sender),
         "permission denied");
        orderList[tokenId] = price;
        orderState[tokenId] = 1;

        emit SellNFT(sender, tokenId, price);
    }

    // 购买
    function buyNFT(uint tokenId) public {
        address sender = msg.sender;
        uint price = orderList[tokenId];
        require(price > 0 &&
        _token.balanceOf(sender) > price 
        && orderState[tokenId] == 1, 
        "Buy failed");

        _token.send(address(this), price, abi.encode(tokenId));
        
        emit BuyNFT(sender, tokenId, price);
    }

    /// 回调处理NFT
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        require(msg.sender == address(_token), "Invalid token");

        uint256 tokenId = abi.decode(userData, (uint256));

        require(orderList[tokenId] == amount, "Wrong price");

        orderState[tokenId] = 2;
        delete orderList[tokenId];

        address nftOwner = _nft.ownerOf(tokenId);

        _token.send(nftOwner, amount, "");
        _nft.safeTransferFrom(nftOwner, from, tokenId);
    }
}

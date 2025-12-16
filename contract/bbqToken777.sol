pragma solidity >=0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/token/ERC777/ERC777.sol";

contract BBQToken is ERC777 {

    constructor()
        ERC777(
            "barbecue",
            "BBQ",
            new address[](0)
        )
    {
        _mint(msg.sender, 10_000_000 * 10 ** decimals(), "", "");
    }
}

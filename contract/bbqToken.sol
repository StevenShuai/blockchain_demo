pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BBQToken is ERC20 {
    
    constructor() ERC20("barbecue", "BBQ") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
}

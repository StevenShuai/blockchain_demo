pragma solidity >=0.8.0;

import "../bbqToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract erc20Bank{
    using SafeERC20 for IERC20;

    // 管理员地址
    address admin;

    mapping(address account => uint) BBQBalances;

    uint totalBanalce;

    // bbq代币合约实例
    BBQToken public token;

    // 事件
    event DepositedERC20(address user, BBQToken token, uint256 amount);
    event WithdrawnERC20(address user, BBQToken token, uint256 amount);
    
    constructor() {
        admin = msg.sender;
    }

    function getBalance(address account) public view returns(address, uint) {
        return (msg.sender, token.balanceOf(account));
    }

    // 用户存入ERO20代币
    function depositERC20(uint amount) public{

        IERC20 etoken = IERC20(token);
        etoken.safeTransferFrom(msg.sender, address(this), amount);
    
        // 更新存款记录
        BBQBalances[msg.sender] += amount;
        totalBanalce += amount;
        
        emit DepositedERC20(msg.sender, token, amount);
    }

    function withdrawERC20() public {
        uint bankBalance = token.balanceOf(address(this));

        token.transfer(msg.sender, bankBalance);

        emit WithdrawnERC20(msg.sender, token, totalBanalce);
        totalBanalce = 0;
    }
}

pragma solidity >=0.8.0;

import "../bbqToken.sol";

interface IBank {
    function withdraw() external;
    function withdrawERC20() external;
}

contract Bank is IBank{
    // 管理员地址
    address admin;

    // 记录地址存款数据
    mapping(address => uint) records;

    mapping(address account => uint) BBQBalances;

    uint totalBanalce;

    // bbq代币合约实例
    BBQToken public token;

    address public bbqAddress;

    // 事件
    event DepositedERC20(address user, uint256 amount);
    event WithdrawnERC20(address user, uint256 amount);

    // 前三名存款地址
    address[3] topDepositors;
    
    constructor() {
        admin = msg.sender;
    }

    receive() external payable {
        deposit(msg.sender, msg.value);
    }

    function deposit (address sender, uint value) public virtual {

        records[sender] += value;
        
        // 是否已经在前三名中
        bool isTopDepositor = false;

        // 判断是否用重新排序
        bool needSort = false;

        for(uint i = 0; i < 3; i++){
            if(topDepositors[i] == sender){
                isTopDepositor = true; 
                needSort = true;
                break;
            }
        }
        if(!isTopDepositor){
            // 如果没在前三名中则判断是否有资格进入前三名并重新排序
            for(uint i = 0; i < 3; i++){
                if(records[sender] > records[topDepositors[i]]){
                    // 如果有资格进入榜单 则放入到数组最后一位
                    topDepositors[2] = sender;
                    needSort = true;
                    break;
                }
            }
        }
        if(needSort){
            // 用冒泡排序重新进行排名
            for(uint j = 0; j < 2; j++){
                for(uint k = 0; k < 2; k++){
                    if(records[topDepositors[k]] < records[topDepositors[k+1]]){
                        (topDepositors[k], topDepositors[k+1]) = (topDepositors[k+1], topDepositors[k]);
                    }
                }
            }
        }
    }

    function getBalance(address account) public view returns(address, uint) {
        return (msg.sender, token.balanceOf(account));
    }

    // 用户存入ERO20代币
    function depositERO20(uint amount) public virtual{

        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    
        // 更新存款记录
        BBQBalances[msg.sender] += amount;
        totalBanalce += amount;
        
        emit DepositedERC20(msg.sender, amount);
    }

    function withdraw() public virtual {
        address payable sender = payable(msg.sender);

        address contractAddress = address(this);
        uint balance = contractAddress.balance;
        require(balance > 0, "No ETH to withdraw");

        sender.transfer(balance);
    }

    function withdrawERC20() public virtual{
        uint bankBalance = token.balanceOf(address(this));

        require(token.transferFrom(address(this), msg.sender, bankBalance), "Transfer failed");

        totalBanalce = 0;

        emit WithdrawnERC20(msg.sender, totalBanalce);
    }

    function getTopDepositors() public view returns (address[3] memory) {
        return topDepositors;
    }

    function getRecords(address user) public view returns (uint) {
        return records[user];
    }
}

contract BigBank is Bank{

    modifier valueVerify(uint amount){
        require(amount>0.001 ether, "Value need more than 0.001 ether");
        _;
    }

    modifier ERC20valueVerify(uint amount){
        require(amount>100, "Value need more than 100");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == admin, "Not owner");
        _;
    }

    // 重写 deposit 函数
    function deposit (address sender, uint amount) public override valueVerify(amount) {
        super.deposit(sender, amount); 
    }

    function setToken(address tokenAddress) public onlyOwner {
        token = BBQToken(tokenAddress);
        bbqAddress = tokenAddress;
    }

    // 用户存入ERO20代币
    function depositERO20(uint256 amount) public override ERC20valueVerify(amount){
        super.depositERO20(amount);
    }

    function withdrawERC20() public override onlyOwner{
        super.withdrawERC20();
    }

    function withdraw() public override onlyOwner{
        super.withdraw();
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function transferAdmin(address newAdmin) public onlyOwner{
        admin = newAdmin;
    }
}

contract Admin{
    address admin;

    modifier onlyOwner(){
        require(msg.sender == admin, "Not owner");
        _;
    }

    constructor(){
        admin = msg.sender;
    }

    receive() external payable {
    }

    function withdraw(IBank bank) public onlyOwner{
        bank.withdraw();
    }

    function withdrawERC20(IBank bank) public onlyOwner{
        bank.withdrawERC20();
    }
}

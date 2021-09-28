// SPDX-License-Identifier: MIT
pragma solidity 0.5.12;
import "./Ownable.sol";

 interface IERC20 {
     function transfer(address to, uint256 value) external returns (bool);
     function approve(address spender, uint256 value) external returns (bool);
     function transferFrom(address from, address to, uint256 value) external returns (bool);
     function totalSupply() external view returns (uint256);
     function balanceOf(address who) external view returns (uint256);
     function allowance(address owner, address spender) external view returns (uint256);
     function mint(address to, uint256 value) external returns (bool);
     function decimals() external view returns(uint8);
 }

contract Game is Ownable {
    IERC20 private MILK2;
    
    struct User {
        bool win;
        uint256 prize;
        bool approve;
    }
    
    mapping(address => User) public users;
    
    address public contractAddress;
    uint256 public decimals;
    
    event OnWithdraw(address indexed _account, uint256 _value);
    
    constructor(address payable mftAddress) public payable {
        MILK2 = IERC20(mftAddress);
        decimals = MILK2.decimals();
        contractAddress = address(this);
    }
    
    modifier hasBalance() {
        require(balanceOfUser() >= 100, 'There are no MILK2 tokens on your balance');
        _;
    }
    
    modifier approved() {
        require(users[msg.sender].approve, 'First you need to approve');
        _;
    }
    
    function balanceOf(address _adr) public view returns(uint256){
        return MILK2.balanceOf(_adr);
    }
    
    function balanceOfContract() public view returns(uint256) {
        return MILK2.balanceOf(address(this));
    }
    
    function balanceOfUser() public view returns (uint256) {
        return MILK2.balanceOf(msg.sender);
    }
    
    function approve() public hasBalance{
        users[msg.sender].approve = true;
    }
    
    function random() private view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.difficulty, now)));
    }
    
    function getPrize() private view returns(uint256){
        uint256 balance = balanceOfUser();
        uint256 prize = (random() % 100) * 10**decimals;
        
        if(balance > 10**4){
            prize *= 10;
        }
        
        return prize;
    }
    
    function play() public payable hasBalance approved{
        uint256 contractBalance = balanceOfContract();
        uint256 prize = getPrize();
        
        require(prize <= contractBalance, 'Not enough MILK2 tokens on the contract balance');
        
        users[msg.sender].prize = prize;
        users[msg.sender].win = true;
        
        MILK2.transfer(msg.sender, prize);
        emit OnWithdraw(msg.sender, prize);
    }
    
    function transferContractBalance(address payable _addr, uint256 _value) public payable onlyOwner{
        MILK2.transfer(_addr, _value);
    }
    
    function getUser(address _addr) public view returns(uint256) {
        return users[_addr].prize;
    }
    
    function allowance(address _addr) public view returns(bool) {
        return users[_addr].approve;
    }

}
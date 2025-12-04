// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// 👤 Owner権限管理の基本パターン
contract SimpleVault is Ownable {
    uint256 public totalDeposits;
    mapping(address => uint256) public balances;
    
    // イベント
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdrawal(address indexed owner, uint256 amount);
    
    // コンストラクタ（デプロイした人がオーナーになる）
    constructor() Ownable(msg.sender) {}
    
    // 誰でも預金できる
    function deposit() public payable {
        require(msg.value > 0, "Must deposit something");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    // 自分のお金を引き出す
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }
    
    // 🔒 オーナーだけが呼び出せる緊急引き出し
    function emergencyWithdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Transfer failed");
        
        emit EmergencyWithdrawal(owner(), balance);
    }
    
    // 🔒 オーナーだけが呼び出せる一時停止機能（例）
    bool public paused = false;
    
    function pause() public onlyOwner {
        paused = true;
    }
    
    function unpause() public onlyOwner {
        paused = false;
    }
    
    // コントラクトの残高確認
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
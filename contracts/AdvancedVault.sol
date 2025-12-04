// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

// 🎭 複数の役割を管理するパターン
contract AdvancedVault is AccessControl {
    // 役割の定義
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    
    uint256 public totalDeposits;
    mapping(address => uint256) public balances;
    bool public paused = false;
    
    // イベント
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Paused(address indexed admin);
    event Unpaused(address indexed admin);
    
    constructor() {
        // デプロイした人に全ての役割を付与
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }
    
    // 誰でも預金できる（一時停止中は不可）
    function deposit() public payable {
        require(!paused, "Contract is paused");
        require(msg.value > 0, "Must deposit something");
        
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        
        emit Deposited(msg.sender, msg.value);
    }
    
    // 自分のお金を引き出す
    function withdraw(uint256 amount) public {
        require(!paused, "Contract is paused");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }
    
    // 🔒 ADMINだけが一時停止できる
    function pause() public onlyRole(ADMIN_ROLE) {
        paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() public onlyRole(ADMIN_ROLE) {
        paused = false;
        emit Unpaused(msg.sender);
    }
    
    // 🔒 MANAGERだけが緊急引き出しできる
    function emergencyWithdraw(address recipient, uint256 amount) 
        public 
        onlyRole(MANAGER_ROLE) 
    {
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    // 🔒 OPERATORだけが統計情報を更新できる（例）
    function updateStatistics() public onlyRole(OPERATOR_ROLE) {
        // 統計情報の更新処理（例）
    }
    
    // 役割の付与（DEFAULT_ADMIN_ROLEを持つ人だけ）
    function grantManagerRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MANAGER_ROLE, account);
    }
    
    function grantOperatorRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(OPERATOR_ROLE, account);
    }
    
    // コントラクトの残高確認
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
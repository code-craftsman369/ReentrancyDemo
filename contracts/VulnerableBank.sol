// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ❌ 脆弱な銀行コントラクト
contract VulnerableBank {
    mapping(address => uint256) public balances;
    
    // 預金
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    // ❌ 危険な引き出し関数
    function withdraw() public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");
        
        // ❌ 問題1: 先に送金している！
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
        
        // ❌ 問題2: 後で残高を更新（攻撃される隙がある！）
        balances[msg.sender] = 0;
    }
    
    // コントラクトの残高確認
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

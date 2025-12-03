const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Reentrancy Attack Demo", function () {
  let bank, attacker;
  let owner, user1, user2, attackerAccount;

  beforeEach(async function () {
    [owner, user1, user2, attackerAccount] = await ethers.getSigners();

    // 脆弱な銀行をデプロイ
    const VulnerableBank = await ethers.getContractFactory("VulnerableBank");
    bank = await VulnerableBank.deploy();

    // 普通のユーザーが預金（被害者）
    await bank.connect(user1).deposit({ value: ethers.parseEther("5") });
    await bank.connect(user2).deposit({ value: ethers.parseEther("5") });

    console.log("\n🏦 初期状態");
    console.log("銀行の残高:", ethers.formatEther(await bank.getBalance()), "ETH");
    console.log("User1の預金:", ethers.formatEther(await bank.balances(user1.address)), "ETH");
    console.log("User2の預金:", ethers.formatEther(await bank.balances(user2.address)), "ETH");

    // 攻撃者のコントラクトをデプロイ
    const Attacker = await ethers.getContractFactory("Attacker");
    attacker = await Attacker.deploy(await bank.getAddress());
  });

  it("🔥 Reentrancy攻撃が成功する", async function () {
    console.log("\n⚔️ 攻撃開始！");

    // 攻撃前の残高
    const bankBalanceBefore = await bank.getBalance();
    console.log("攻撃前の銀行残高:", ethers.formatEther(bankBalanceBefore), "ETH");

    // 攻撃実行（1 ETHで攻撃）
    await attacker.connect(attackerAccount).attack({ value: ethers.parseEther("1") });

    // 攻撃後の残高
    const bankBalanceAfter = await bank.getBalance();
    const stolenAmount = await attacker.getStolen();
    const attackCount = await attacker.attackCount();

    console.log("\n💥 攻撃結果");
    console.log("攻撃後の銀行残高:", ethers.formatEther(bankBalanceAfter), "ETH");
    console.log("攻撃者が盗んだ金額:", ethers.formatEther(stolenAmount), "ETH");
    console.log("攻撃回数:", attackCount.toString(), "回");

    // 攻撃が成功したことを確認
    expect(stolenAmount).to.be.gt(ethers.parseEther("1")); // 1 ETH以上盗んだ
    console.log("\n🎯 攻撃成功！銀行からお金を盗みました！");
  });
  it("🛡️ 安全な銀行は攻撃を防げる", async function () {
    // 安全な銀行をデプロイ
    const SecureBank = await ethers.getContractFactory("SecureBank");
    const secureBank = await SecureBank.deploy();

    // 普通のユーザーが預金
    await secureBank.connect(user1).deposit({ value: ethers.parseEther("5") });
    await secureBank.connect(user2).deposit({ value: ethers.parseEther("5") });

    console.log("\n🏦 安全な銀行の初期状態");
    console.log("銀行の残高:", ethers.formatEther(await secureBank.getBalance()), "ETH");

    // 攻撃者のコントラクトをデプロイ（安全な銀行を攻撃対象に）
    const AttackerOnSecure = await ethers.getContractFactory("Attacker");
    const attackerOnSecure = await AttackerOnSecure.deploy(await secureBank.getAddress());

    console.log("\n⚔️ 安全な銀行への攻撃開始！");

    // 攻撃を試みる
    await attackerOnSecure.connect(attackerAccount).attack({ value: ethers.parseEther("1") });

    // 結果確認
    const bankBalanceAfter = await secureBank.getBalance();
    const stolenAmount = await attackerOnSecure.getStolen();

    console.log("\n🛡️ 防御結果");
    console.log("攻撃後の銀行残高:", ethers.formatEther(bankBalanceAfter), "ETH");
    console.log("攻撃者が盗めた金額:", ethers.formatEther(stolenAmount), "ETH");

    // 攻撃が失敗したことを確認
    expect(stolenAmount).to.equal(ethers.parseEther("1")); // 1 ETHしか引き出せない
    expect(bankBalanceAfter).to.equal(ethers.parseEther("10")); // 銀行は10 ETH残っている
    console.log("\n✅ 攻撃失敗！銀行は安全です！");
  });

});

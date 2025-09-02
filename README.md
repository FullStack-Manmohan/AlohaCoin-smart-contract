# 🏝️ AlohaCoin (ALOHA)

AlohaCoin is a next-generation meme coin designed for the community with secure, deflationary tokenomics, real utility, and long-term aligned incentives.

---

## 📌 Token Overview

- **Token Name:** AlohaCoin
- **Symbol:** ALOHA
- **Total Supply:** 1,000,000,000 ALOHA
- **Decimals:** 18

---

## 🚀 Key Features

### ✅ Reflection Rewards
- 1% of each transaction is redirected to the **Reflection Pool** for redistribution to holders.
- Rewards accumulate and can be automated or triggered via off-chain distribution.

### 🔥 Deflationary Burn Mechanism
- 1% of every transaction is permanently burned.
- Reduces total supply, increasing scarcity over time.

### 🛡️ Anti-Whale Protection
- Limits max transaction size and max wallet holdings.
- Helps reduce manipulation and ensure healthy distribution.

### 🧊 Dev Wallet Vesting
- 15% of the supply is allocated to devs with a 24-month time-locked vesting contract.
- Only a portion can be claimed monthly using `claimDevTokens()`.

### 🚫 Blacklisting & Exclusion Logic
- Bad actors can be blacklisted from transfers.
- Exchange and staking contracts can be fee-exempt.

### ⛓️ Upgrade-Ready Architecture
- Modular design makes it extensible for future governance, staking, and DAO integrations.

---

## 🧪 Deployment Info

| Network     | Status     | Contract Address                            |
|-------------|------------|---------------------------------------------|
| BSC Testnet | ✅ Deployed| `0xYourTestnetContractAddressHere`          |
| BSC Mainnet | 🔜 Pending | *To be deployed after testnet validation*   |

---

## 💼 Dev Vesting Contract

- Dev wallet receives locked ALOHA at deployment.
- Vesting is enforced via time-based claim logic.
- Claim function: `claimDevTokens()`
- Claimable only once per month.

---

## 💸 How to Interact

### 🟢 Transfer Tokens

```solidity
transfer(recipient, amount);
```

### 🔓 Claim Dev Tokens

```solidity
claimDevTokens();
```

- Can only be called by the dev wallet.
- Checks that at least 30 days have passed since the last claim.

---

## 🔍 Verifying on BscScan

After deployment:

1. Visit [https://bscscan.com](https://bscscan.com) (mainnet) or [https://testnet.bscscan.com](https://testnet.bscscan.com)
2. Search for your contract address
3. Click **"Verify and Publish"**
4. Compiler: `v0.8.20`
5. Optimization: **Yes**
6. Constructor Arguments:  
   Provide `0xDevWallet` and `0xReflectionPool` as inputs

---

## 🔐 Security Commitment

AlohaCoin is built with industry best practices using battle-tested OpenZeppelin contracts.

- ✅ Max transfer limits (anti-whale)
- ✅ Fee cap enforcement (≤10%)
- ✅ Dev vesting enforced on-chain
- ✅ Reflection and burn logic
- ✅ Manual + testnet validation complete
- 🔒 Audit to be scheduled before full mainnet promotion

---

## 🌴 Aloha Vibes. Serious Code.

Built for the people. Auditable, fair, and optimized for long-term utility.

**Website:** [https://alohacoin.ai](https://alohacoin.ai)  
**Twitter (X):** [https://twitter.com/AlohaCoinHQ](https://twitter.com/AlohaCoinHQ)

---
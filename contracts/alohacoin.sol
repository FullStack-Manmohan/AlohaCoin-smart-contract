// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// ✅ Use local path after installing
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title AlohaCoin V3
 * @notice Mainnet-Ready Meme Coin for Community, Fun, and Passive Rewards
 * @dev Features: Reflection, Burn, Dev Vesting, Anti-Whale, Blacklist, Upgrade-Ready
 */
contract AlohaCoin is ERC20, Ownable, ReentrancyGuard {
    // --- Tokenomics ---
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;
    uint256 public constant VESTED_AMOUNT = 50_000_000 * 10 ** 18;

    uint256 public burnFee = 1;
    uint256 public reflectionFee = 1;
    uint256 public devFee = 2;
    uint256 public marketingFee = 2;
    uint256 public constant FEE_CAP = 10;

    address public devWallet;
    address public marketingWallet;
    address public reflectionPool;

    uint256 public maxTxAmount;
    uint256 public maxWalletAmount;
    bool public tradingEnabled = false;
    uint256 public launchTime;
    uint256 public launchProtectionDuration = 60;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public isBlacklisted;

    // --- Vesting State ---
    uint256 public vestingStart;
    uint256 public vestingDuration = 730 days; // 24 months
    uint256 public totalClaimed;

    // --- Events ---
    event FeesUpdated(uint256 burn, uint256 reflection, uint256 dev, uint256 marketing);
    event DevWalletUpdated(address oldWallet, address newWallet);
    event MarketingWalletUpdated(address oldWallet, address newWallet);
    event ReflectionPoolUpdated(address oldPool, address newPool);
    event ExcludedFromFee(address account, bool excluded);
    event BlacklistUpdated(address wallet, bool status);
    event DevTokensClaimed(address indexed to, uint256 amount);
    event TradingEnabled(uint256 startTime);
    event MaxWalletUpdated(uint256 amount);

    constructor(address _devWallet, address _marketingWallet, address _reflectionPool)
        ERC20("Aloha Coin", "ALOHA")
    {
        require(_devWallet != address(0), "Invalid dev wallet");
        require(_marketingWallet != address(0), "Invalid marketing wallet");
        require(_reflectionPool != address(0), "Invalid reflection pool");

        devWallet = _devWallet;
        marketingWallet = _marketingWallet;
        reflectionPool = _reflectionPool;

        _mint(msg.sender, MAX_SUPPLY - VESTED_AMOUNT); // Public + liquidity
        _mint(address(this), VESTED_AMOUNT); // Locked for vesting

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[devWallet] = true;
        _isExcludedFromFee[marketingWallet] = true;
        _isExcludedFromFee[reflectionPool] = true;
        _isExcludedFromFee[address(this)] = true;

        maxTxAmount = MAX_SUPPLY / 50; // 2% anti-whale
        maxWalletAmount = MAX_SUPPLY / 50; // 2% anti-whale
        vestingStart = block.timestamp;
    }

    // --- Fee Controls ---
    function setFees(uint256 _burn, uint256 _reflection, uint256 _dev, uint256 _marketing) external onlyOwner {
        require(_burn + _reflection + _dev + _marketing <= FEE_CAP, "Total fee too high");
        burnFee = _burn;
        reflectionFee = _reflection;
        devFee = _dev;
        marketingFee = _marketing;
        emit FeesUpdated(_burn, _reflection, _dev, _marketing);
    }

    function setDevWallet(address _newWallet) external onlyOwner {
        require(_newWallet != address(0), "Invalid wallet");
        address old = devWallet;
        devWallet = _newWallet;
        emit DevWalletUpdated(old, _newWallet);
    }

    function setMarketingWallet(address _newWallet) external onlyOwner {
        require(_newWallet != address(0), "Invalid wallet");
        address old = marketingWallet;
        marketingWallet = _newWallet;
        emit MarketingWalletUpdated(old, _newWallet);
    }

    function setReflectionPool(address _newPool) external onlyOwner {
        require(_newPool != address(0), "Invalid pool");
        address old = reflectionPool;
        reflectionPool = _newPool;
        emit ReflectionPoolUpdated(old, _newPool);
    }

    function excludeFromFee(address account, bool excluded) external onlyOwner {
        _isExcludedFromFee[account] = excluded;
        emit ExcludedFromFee(account, excluded);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    // --- Vesting ---
    function claimDevTokens() external nonReentrant {
        require(msg.sender == devWallet, "Only dev");
        uint256 claimable = vestedAmount();
        require(claimable > 0, "Nothing to claim");

        totalClaimed += claimable;
        _transfer(address(this), devWallet, claimable);
        emit DevTokensClaimed(devWallet, claimable);
    }

    function vestedAmount() public view returns (uint256) {
        if (block.timestamp < vestingStart) return 0;
        uint256 elapsed = block.timestamp - vestingStart;
        if (elapsed >= vestingDuration) return VESTED_AMOUNT - totalClaimed;
        return (VESTED_AMOUNT * elapsed / vestingDuration) - totalClaimed;
    }

    // --- Anti-Whale & Blacklist ---
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Already enabled");
        tradingEnabled = true;
        launchTime = block.timestamp;
        emit TradingEnabled(launchTime);
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        require(amount > 0, "Must be > 0");
        maxTxAmount = amount;
    }

    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        require(amount > 0, "Must be > 0");
        maxWalletAmount = amount;
        emit MaxWalletUpdated(amount);
    }

    function blacklistAddress(address wallet, bool status) external onlyOwner {
        isBlacklisted[wallet] = status;
        emit BlacklistUpdated(wallet, status);
    }

    // --- Transfer Logic ---
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Blacklisted");

        if (!tradingEnabled) {
            require(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "Trading not active");
        }

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            super._transfer(sender, recipient, amount);
            return;
        }

        require(amount <= maxTxAmount, "Exceeds max tx");

        // Max wallet check
        if (recipient != reflectionPool && recipient != devWallet && recipient != marketingWallet && recipient != address(0) && recipient != address(this)) {
             require(balanceOf(recipient) + amount <= maxWalletAmount, "Exceeds max wallet");
        }

        uint256 burnAmount = (amount * burnFee) / 100;
        uint256 reflectAmount = (amount * reflectionFee) / 100;
        uint256 devAmount = (amount * devFee) / 100;
        uint256 marketingAmount = (amount * marketingFee) / 100;

        uint256 totalFee = burnAmount + reflectAmount + devAmount + marketingAmount;
        uint256 transferAmount = amount - totalFee;

        if (burnAmount > 0) _burn(sender, burnAmount);
        if (reflectAmount > 0) super._transfer(sender, reflectionPool, reflectAmount);
        if (devAmount > 0) super._transfer(sender, devWallet, devAmount);
        if (marketingAmount > 0) super._transfer(sender, marketingWallet, marketingAmount);

        super._transfer(sender, recipient, transferAmount);
    }

    function reflectionPoolBalance() external view returns (uint256) {
        return balanceOf(reflectionPool);
    }
}
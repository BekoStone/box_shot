// File: lib/game/managers/coin_manager.dart

// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import '../../services/asset_manager.dart';
import 'power_up_manager.dart';

class CoinManager {
  static const String _coinsKey = 'player_coins';
  static const String _totalEarnedKey = 'total_coins_earned';
  
  int _currentCoins = 0;
  int _totalEarned = 0;
  
  // Getters
  int get currentCoins => _currentCoins;
  int get totalEarned => _totalEarned;
  
  // ✅ Coin earning rates
  static const Map<String, int> coinRewards = {
    'block_placed': 1,        // Per block placed
    'line_cleared': 10,       // Per line cleared
    'combo_2x': 20,          // 2x combo bonus
    'combo_3x': 35,          // 3x combo bonus  
    'combo_4x': 50,          // 4x combo bonus
    'combo_5x': 75,          // 5x combo bonus
    'perfect_clear': 100,    // Clear entire board
    'game_complete': 25,     // Finish a game
    'high_score': 50,        // Beat personal best
    'daily_login': 25,       // Daily login bonus
    'achievement': 100,      // Achievement unlocked
  };

  // ✅ Power-up store prices
  static const Map<PowerUpType, int> storePrices = {
    PowerUpType.hammer: 50,
    PowerUpType.bomb: 100,
    PowerUpType.shuffle: 75,
    PowerUpType.hint: 25,
    PowerUpType.freeze: 30,
  };

  // ✅ Bundle deals (better value)
  static const Map<String, Map<String, dynamic>> bundles = {
    'starter_pack': {
      'name': 'Starter Pack',
      'price': 200,
      'description': '3 of each power-up',
      'contents': {
        PowerUpType.hammer: 3,
        PowerUpType.bomb: 3,
        PowerUpType.shuffle: 3,
        PowerUpType.hint: 5,
        PowerUpType.freeze: 3,
      }
    },
    'power_pack': {
      'name': 'Power Pack', 
      'price': 500,
      'description': '10 hammers + 5 bombs',
      'contents': {
        PowerUpType.hammer: 10,
        PowerUpType.bomb: 5,
      }
    },
    'strategic_pack': {
      'name': 'Strategic Pack',
      'price': 300,
      'description': '10 hints + 10 shuffles',
      'contents': {
        PowerUpType.hint: 10,
        PowerUpType.shuffle: 10,
      }
    }
  };

  // ✅ Initialize coin system
  Future<void> initialize() async {
    await _loadCoins();
    print('💰 Coin system initialized: $_currentCoins coins');
  }

  // ✅ Load coins from storage
  Future<void> _loadCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentCoins = prefs.getInt(_coinsKey) ?? 100; // Start with 100 coins
      _totalEarned = prefs.getInt(_totalEarnedKey) ?? 0;
    } catch (e) {
      print('❌ Failed to load coins: $e');
      _currentCoins = 100;
      _totalEarned = 0;
    }
  }

  // ✅ Save coins to storage
  Future<void> _saveCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinsKey, _currentCoins);
      await prefs.setInt(_totalEarnedKey, _totalEarned);
    } catch (e) {
      print('❌ Failed to save coins: $e');
    }
  }

  // ✅ Award coins for gameplay actions
  void awardCoins(String reason, {int? customAmount}) {
    final amount = customAmount ?? coinRewards[reason] ?? 0;
    
    if (amount <= 0) return;
    
    _currentCoins += amount;
    _totalEarned += amount;
    
    print('💰 +$amount coins for $reason (Total: $_currentCoins)');
    AssetManager.playSfx('sfx_reward');
    
    _saveCoins();
  }

  // ✅ Award combo bonus coins
  void awardComboBonus(int comboLevel) {
    final baseBonus = coinRewards['line_cleared'] ?? 10;
    final comboMultiplier = (comboLevel * 0.5).clamp(1.0, 3.0);
    final bonusCoins = (baseBonus * comboMultiplier).round();
    
    awardCoins('combo_bonus', customAmount: bonusCoins);
  }

  // ✅ Award streak bonus coins  
  void awardStreakBonus(int streakCount) {
    if (streakCount < 3) return;
    
    final bonusCoins = streakCount * 5;
    awardCoins('streak_bonus', customAmount: bonusCoins);
  }

  // ✅ Check if player can afford item
  bool canAfford(int price) {
    return _currentCoins >= price;
  }

  // ✅ Spend coins
  bool spendCoins(int amount, String reason) {
    if (!canAfford(amount)) {
      print('❌ Insufficient coins for $reason (need $amount, have $_currentCoins)');
      return false;
    }
    
    _currentCoins -= amount;
    print('💸 Spent $amount coins on $reason (Remaining: $_currentCoins)');
    
    AssetManager.playSfx('sfx_click');
    _saveCoins();
    return true;
  }

  // ✅ Purchase single power-up
  bool purchasePowerUp(PowerUpType type, PowerUpManager powerUpManager) {
    final price = storePrices[type];
    if (price == null) return false;
    
    if (!canAfford(price)) {
      print('❌ Cannot afford ${PowerUpManager.powerUps[type]!.name}');
      return false;
    }
    
    if (spendCoins(price, PowerUpManager.powerUps[type]!.name)) {
      powerUpManager.addPowerUp(type, 1);
      print('✅ Purchased ${PowerUpManager.powerUps[type]!.name}');
      return true;
    }
    
    return false;
  }

  // ✅ Purchase bundle
  bool purchaseBundle(String bundleKey, PowerUpManager powerUpManager) {
    final bundle = bundles[bundleKey];
    if (bundle == null) return false;
    
    final price = bundle['price'] as int;
    final name = bundle['name'] as String;
    final contents = bundle['contents'] as Map<PowerUpType, int>;
    
    if (!canAfford(price)) {
      print('❌ Cannot afford $name bundle');
      return false;
    }
    
    if (spendCoins(price, name)) {
      // Add all power-ups from bundle
      for (final entry in contents.entries) {
        powerUpManager.addPowerUp(entry.key, entry.value);
      }
      
      print('✅ Purchased $name bundle');
      return true;
    }
    
    return false;
  }

  // ✅ Daily login bonus
  Future<bool> claimDailyBonus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastClaimDate = prefs.getString('last_daily_claim') ?? '';
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      if (lastClaimDate == today) {
        print('❌ Daily bonus already claimed today');
        return false;
      }
      
      // Award daily bonus
      awardCoins('daily_login');
      
      // Save claim date
      await prefs.setString('last_daily_claim', today);
      
      print('🎁 Daily bonus claimed!');
      return true;
    } catch (e) {
      print('❌ Failed to claim daily bonus: $e');
      return false;
    }
  }

  // ✅ Watch ad for coins (simulate for now)
  void watchAdForCoins() {
    final bonusCoins = 50;
    awardCoins('ad_reward', customAmount: bonusCoins);
    print('📺 Watched ad for $bonusCoins coins');
  }

  // ✅ Free coins for sharing
  void awardSharingBonus() {
    awardCoins('sharing_bonus', customAmount: 25);
    print('📱 Shared game for bonus coins');
  }

  // ✅ Get affordable power-ups
  List<PowerUpType> getAffordablePowerUps() {
    return storePrices.entries
        .where((entry) => canAfford(entry.value))
        .map((entry) => entry.key)
        .toList();
  }

  // ✅ Get affordable bundles
  List<String> getAffordableBundles() {
    return bundles.entries
        .where((entry) => canAfford(entry.value['price'] as int))
        .map((entry) => entry.key)
        .toList();
  }

  // ✅ Calculate savings for bundles
  int calculateBundleSavings(String bundleKey) {
    final bundle = bundles[bundleKey];
    if (bundle == null) return 0;
    
    final bundlePrice = bundle['price'] as int;
    final contents = bundle['contents'] as Map<PowerUpType, int>;
    
    int individualPrice = 0;
    for (final entry in contents.entries) {
      final powerUpPrice = storePrices[entry.key] ?? 0;
      individualPrice += powerUpPrice * entry.value;
    }
    
    return individualPrice - bundlePrice;
  }

  // ✅ Get coin earning statistics
  Map<String, dynamic> getEarningStats() {
    return {
      'currentCoins': _currentCoins,
      'totalEarned': _totalEarned,
      'totalSpent': _totalEarned - _currentCoins,
      'averagePerGame': _totalEarned / 1, // Could track games played
    };
  }

  // ✅ Emergency coin grant (for testing/support)
  void grantCoins(int amount, String reason) {
    _currentCoins += amount;
    _totalEarned += amount;
    print('🎁 Granted $amount coins: $reason');
    _saveCoins();
  }

  // ✅ Reset coins (for testing)
  void resetCoins() {
    _currentCoins = 100;
    _totalEarned = 0;
    _saveCoins();
    print('🔄 Coins reset to 100');
  }

  // ✅ Print detailed status
  void printStatus() {
    print('💰 COIN STATUS:');
    print('   Current: $_currentCoins coins');
    print('   Total Earned: $_totalEarned coins');
    print('   Total Spent: ${_totalEarned - _currentCoins} coins');
    
    print('\n🛒 AFFORDABLE POWER-UPS:');
    for (final type in getAffordablePowerUps()) {
      final data = PowerUpManager.powerUps[type]!;
      final price = storePrices[type]!;
      print('   ${data.icon} ${data.name}: $price coins');
    }
    
    print('\n📦 AFFORDABLE BUNDLES:');
    for (final bundleKey in getAffordableBundles()) {
      final bundle = bundles[bundleKey]!;
      final savings = calculateBundleSavings(bundleKey);
      print('   ${bundle['name']}: ${bundle['price']} coins (Save $savings)');
    }
  }
}
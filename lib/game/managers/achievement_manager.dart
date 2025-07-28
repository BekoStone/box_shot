import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../services/asset_manager.dart';
import 'coin_manager.dart';
import 'power_up_manager.dart';

enum AchievementCategory {
  beginner,
  scoring,
  combo,
  survival,
  mastery,
  special,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int targetValue;
  final int coinReward;
  final PowerUpType? powerUpReward;
  final int powerUpCount;
  final Color color;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    required this.coinReward,
    this.powerUpReward,
    this.powerUpCount = 1,
    required this.color,
    this.isSecret = false,
  });
}

class AchievementProgress {
  final String achievementId;
  int currentValue;
  bool isUnlocked;
  DateTime? unlockedAt;

  AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentValue': currentValue,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'],
      currentValue: json['currentValue'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
    );
  }
}

class AchievementManager {
  // ✅ All achievements definition
  static const List<Achievement> allAchievements = [
    // 🌟 BEGINNER ACHIEVEMENTS
    Achievement(
      id: 'first_block',
      name: 'First Steps',
      description: 'Place your first block',
      icon: '🎯',
      category: AchievementCategory.beginner,
      targetValue: 1,
      coinReward: 25,
      color: Colors.green,
    ),
    Achievement(
      id: 'first_line',
      name: 'Line Breaker',
      description: 'Clear your first line',
      icon: '📏',
      category: AchievementCategory.beginner,
      targetValue: 1,
      coinReward: 50,
      powerUpReward: PowerUpType.hammer,
      color: Colors.blue,
    ),
    Achievement(
      id: 'play_10_games',
      name: 'Getting Started',
      description: 'Play 10 games',
      icon: '🎮',
      category: AchievementCategory.beginner,
      targetValue: 10,
      coinReward: 100,
      powerUpReward: PowerUpType.shuffle,
      color: Colors.orange,
    ),

    // 🏆 SCORING ACHIEVEMENTS
    Achievement(
      id: 'score_1000',
      name: 'Rising Star',
      description: 'Score 1,000 points in a single game',
      icon: '⭐',
      category: AchievementCategory.scoring,
      targetValue: 1000,
      coinReward: 75,
      color: Colors.yellow,
    ),
    Achievement(
      id: 'score_5000',
      name: 'High Scorer',
      description: 'Score 5,000 points in a single game',
      icon: '🌟',
      category: AchievementCategory.scoring,
      targetValue: 5000,
      coinReward: 150,
      powerUpReward: PowerUpType.bomb,
      color: Colors.amber,
    ),
    Achievement(
      id: 'score_10000',
      name: 'Score Master',
      description: 'Score 10,000 points in a single game',
      icon: '💫',
      category: AchievementCategory.scoring,
      targetValue: 10000,
      coinReward: 300,
      powerUpReward: PowerUpType.bomb,
      powerUpCount: 3,
      color: Colors.purple,
    ),

    // 🔥 COMBO ACHIEVEMENTS
    Achievement(
      id: 'combo_3x',
      name: 'Combo Starter',
      description: 'Achieve a 3x combo',
      icon: '🔥',
      category: AchievementCategory.combo,
      targetValue: 3,
      coinReward: 100,
      color: Colors.red,
    ),
    Achievement(
      id: 'combo_5x',
      name: 'Combo Master',
      description: 'Achieve a 5x combo',
      icon: '💥',
      category: AchievementCategory.combo,
      targetValue: 5,
      coinReward: 200,
      powerUpReward: PowerUpType.hint,
      powerUpCount: 5,
      color: Colors.deepOrange,
    ),
    Achievement(
      id: 'perfect_clear',
      name: 'Perfect Storm',
      description: 'Clear the entire board',
      icon: '⚡',
      category: AchievementCategory.combo,
      targetValue: 1,
      coinReward: 500,
      powerUpReward: PowerUpType.bomb,
      powerUpCount: 2,
      color: Colors.indigo,
    ),

    // ⏱️ SURVIVAL ACHIEVEMENTS
    Achievement(
      id: 'survive_5min',
      name: 'Survivor',
      description: 'Play for 5 minutes straight',
      icon: '⏰',
      category: AchievementCategory.survival,
      targetValue: 300, // 5 minutes in seconds
      coinReward: 150,
      color: Colors.teal,
    ),
    Achievement(
      id: 'no_undo_game',
      name: 'Pure Skill',
      description: 'Complete a game without using undo',
      icon: '🎯',
      category: AchievementCategory.survival,
      targetValue: 1,
      coinReward: 200,
      powerUpReward: PowerUpType.freeze,
      powerUpCount: 3,
      color: Colors.cyan,
    ),
    Achievement(
      id: 'place_100_blocks',
      name: 'Block Buster',
      description: 'Place 100 blocks total',
      icon: '🧱',
      category: AchievementCategory.survival,
      targetValue: 100,
      coinReward: 100,
      color: Colors.brown,
    ),

    // 🎓 MASTERY ACHIEVEMENTS  
    Achievement(
      id: 'clear_50_lines',
      name: 'Line Cleaner',
      description: 'Clear 50 lines total',
      icon: '🧹',
      category: AchievementCategory.mastery,
      targetValue: 50,
      coinReward: 250,
      color: Colors.green,
    ),
    Achievement(
      id: 'reach_level_10',
      name: 'Level Master',
      description: 'Reach level 10',
      icon: '🏅',
      category: AchievementCategory.mastery,
      targetValue: 10,
      coinReward: 300,
      powerUpReward: PowerUpType.hammer,
      powerUpCount: 5,
      color: Colors.purple,
    ),

    // 🎊 SPECIAL SECRET ACHIEVEMENTS
    Achievement(
      id: 'secret_pattern',
      name: 'Pattern Genius',
      description: 'Discover the secret...',
      icon: '🎭',
      category: AchievementCategory.special,
      targetValue: 1,
      coinReward: 1000,
      powerUpReward: PowerUpType.bomb,
      powerUpCount: 10,
      color: Colors.black,
      isSecret: true,
    ),
    Achievement(
      id: 'lucky_777',
      name: 'Lucky Seven',
      description: 'Score exactly 777 points',
      icon: '🍀',
      category: AchievementCategory.special,
      targetValue: 777,
      coinReward: 777,
      color: Colors.green,
      isSecret: true,
    ),
  ];

  // ✅ Progress tracking
  final Map<String, AchievementProgress> _progress = {};
  final List<String> _recentlyUnlocked = [];

  // Initialize achievement system
  Future<void> initialize() async {
    await _loadProgress();
    print('🏆 Achievement system initialized with ${_progress.length} tracked achievements');
  }

  // ✅ Load progress from storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('achievement_progress') ?? '{}';
      final Map<String, dynamic> savedProgress = {};
      
      // Parse saved progress safely
      try {
        savedProgress.addAll(Map<String, dynamic>.from({}));
      } catch (e) {
        print('Failed to parse achievement progress: $e');
      }

      // Initialize progress for all achievements
      for (final achievement in allAchievements) {
        if (savedProgress.containsKey(achievement.id)) {
          _progress[achievement.id] = AchievementProgress.fromJson(
            savedProgress[achievement.id]
          );
        } else {
          _progress[achievement.id] = AchievementProgress(
            achievementId: achievement.id
          );
        }
      }
    } catch (e) {
      print('❌ Failed to load achievement progress: $e');
      // Initialize empty progress for all achievements
      for (final achievement in allAchievements) {
        _progress[achievement.id] = AchievementProgress(
          achievementId: achievement.id
        );
      }
    }
  }

  // ✅ Save progress to storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = <String, dynamic>{};
      
      for (final entry in _progress.entries) {
        progressMap[entry.key] = entry.value.toJson();
      }
      
      await prefs.setString('achievement_progress', progressMap.toString());
    } catch (e) {
      print('❌ Failed to save achievement progress: $e');
    }
  }

  // ✅ Update achievement progress
  bool updateProgress(String achievementId, int value, {bool increment = false}) {
    final progress = _progress[achievementId];
    if (progress == null || progress.isUnlocked) {
      return false; // Achievement doesn't exist or already unlocked
    }

    final achievement = allAchievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw ArgumentError('Achievement $achievementId not found'),
    );

    // Update progress value
    if (increment) {
      progress.currentValue += value;
    } else {
      progress.currentValue = value;
    }

    // Check if achievement is now completed
    if (progress.currentValue >= achievement.targetValue && !progress.isUnlocked) {
      _unlockAchievement(achievementId);
      return true;
    }

    _saveProgress();
    return false;
  }

  // ✅ Unlock achievement
  void _unlockAchievement(String achievementId) {
    final progress = _progress[achievementId];
    final achievement = allAchievements.firstWhere((a) => a.id == achievementId);
    
    if (progress == null || progress.isUnlocked) return;

    // Mark as unlocked
    progress.isUnlocked = true;
    progress.unlockedAt = DateTime.now();
    
    // Add to recently unlocked for UI display
    _recentlyUnlocked.add(achievementId);
    
    print('🏆 ACHIEVEMENT UNLOCKED: ${achievement.name}');
    print('   ${achievement.description}');
    print('   Reward: ${achievement.coinReward} coins');
    
    // Play achievement sound
    AssetManager.playSfx('sfx_win');
    
    _saveProgress();
  }

  // ✅ Grant achievement rewards
  void grantRewards(String achievementId, CoinManager coinManager, PowerUpManager powerUpManager) {
    final achievement = allAchievements.firstWhere((a) => a.id == achievementId);
    final progress = _progress[achievementId];
    
    if (progress == null || !progress.isUnlocked) return;

    // Grant coin reward
    if (achievement.coinReward > 0) {
      coinManager.awardCoins('achievement', customAmount: achievement.coinReward);
    }

    // Grant power-up reward
    if (achievement.powerUpReward != null) {
      powerUpManager.addPowerUp(achievement.powerUpReward!, achievement.powerUpCount);
      print('🎁 Awarded ${achievement.powerUpCount}x ${PowerUpManager.powerUps[achievement.powerUpReward!]!.name}');
    }
  }

  // ✅ Common achievement triggers
  void onBlockPlaced() {
    updateProgress('first_block', 1);
    updateProgress('place_100_blocks', 1, increment: true);
  }

  void onLineCleared(int lineCount) {
    if (lineCount > 0) {
      updateProgress('first_line', 1);
      updateProgress('clear_50_lines', lineCount, increment: true);
    }
  }

  void onScoreAchieved(int score) {
    updateProgress('score_1000', score);
    updateProgress('score_5000', score);
    updateProgress('score_10000', score);
    
    // Secret lucky 777 achievement
    if (score == 777) {
      updateProgress('lucky_777', score);
    }
  }

  void onComboAchieved(int comboLevel) {
    updateProgress('combo_3x', comboLevel);
    updateProgress('combo_5x', comboLevel);
  }

  void onPerfectClear() {
    updateProgress('perfect_clear', 1);
  }

  void onGameCompleted(bool usedUndo) {
    updateProgress('play_10_games', 1, increment: true);
    
    if (!usedUndo) {
      updateProgress('no_undo_game', 1);
    }
  }

  void onLevelReached(int level) {
    updateProgress('reach_level_10', level);
  }

  void onGameDuration(int seconds) {
    updateProgress('survive_5min', seconds);
  }

  // ✅ Get achievement info
  Achievement? getAchievement(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  AchievementProgress? getProgress(String id) {
    return _progress[id];
  }

  // ✅ Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }

  // ✅ Get unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return allAchievements.where((a) {
      final progress = _progress[a.id];
      return progress?.isUnlocked ?? false;
    }).toList();
  }

  // ✅ Get locked achievements (excluding secrets)
  List<Achievement> getLockedAchievements({bool includeSecret = false}) {
    return allAchievements.where((a) {
      final progress = _progress[a.id];
      final isLocked = !(progress?.isUnlocked ?? false);
      return isLocked && (includeSecret || !a.isSecret);
    }).toList();
  }

  // ✅ Get recently unlocked achievements
  List<String> getRecentlyUnlocked() {
    final recent = List<String>.from(_recentlyUnlocked);
    _recentlyUnlocked.clear(); // Clear after reading
    return recent;
  }

  // ✅ Get completion percentage
  double getCompletionPercentage() {
    final unlockedCount = getUnlockedAchievements().length;
    final totalCount = allAchievements.where((a) => !a.isSecret).length;
    return (unlockedCount / totalCount * 100).clamp(0.0, 100.0);
  }

  // ✅ Get total coins earned from achievements
  int getTotalCoinsEarned() {
    int total = 0;
    for (final achievement in getUnlockedAchievements()) {
      total += achievement.coinReward;
    }
    return total;
  }

  // ✅ Check if player has any near-completion achievements
  List<Achievement> getNearCompletionAchievements({double threshold = 0.8}) {
    final List<Achievement> nearCompletion = [];
    
    for (final achievement in allAchievements) {
      final progress = _progress[achievement.id];
      if (progress != null && !progress.isUnlocked) {
        final completionRatio = progress.currentValue / achievement.targetValue;
        if (completionRatio >= threshold) {
          nearCompletion.add(achievement);
        }
      }
    }
    
    return nearCompletion;
  }

  // ✅ Debug print all achievements
  void printAllAchievements() {
    print('🏆 ALL ACHIEVEMENTS:');
    
    for (final category in AchievementCategory.values) {
      final categoryAchievements = getAchievementsByCategory(category);
      if (categoryAchievements.isNotEmpty) {
        print('\n📂 ${category.name.toUpperCase()}:');
        
        for (final achievement in categoryAchievements) {
          final progress = _progress[achievement.id];
          final status = progress?.isUnlocked == true ? '✅' : '🔒';
          final progressText = progress?.isUnlocked == true 
              ? 'UNLOCKED'
              : '${progress?.currentValue ?? 0}/${achievement.targetValue}';
          
          print('   $status ${achievement.icon} ${achievement.name}: $progressText');
          print('      ${achievement.description}');
          print('      Reward: ${achievement.coinReward} coins${achievement.powerUpReward != null ? ' + ${achievement.powerUpCount}x ${PowerUpManager.powerUps[achievement.powerUpReward!]!.name}' : ''}');
        }
      }
    }
    
    print('\n📊 COMPLETION: ${getCompletionPercentage().toStringAsFixed(1)}%');
    print('💰 Total Achievement Coins: ${getTotalCoinsEarned()}');
  }
}
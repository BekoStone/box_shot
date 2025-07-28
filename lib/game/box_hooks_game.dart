// File: lib/game/box_hooks_game.dart - COMPLETE REPLACEMENT

// ignore_for_file: avoid_print

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import '../services/asset_manager.dart';
import 'game_state.dart';
import 'components/game_scene.dart';
import 'managers/power_up_manager.dart'; // ✅ NEW

class BoxHooksGame extends FlameGame with DragCallbacks, TapCallbacks, HasCollisionDetection {
  GameState currentState = GameState.splash;

  // ✅ FIXED: Proper null safety with nullable _gameScene
  GameScene? _gameScene;

  @override
  Future<void> onLoad() async {
    await AssetManager.preloadAssets();
    // Game scene is initialized only when game starts
  }

  void showMainMenu() {
    overlays.remove('AnimatedSplash');
    overlays.add('MainMenu');
    currentState = GameState.menu;
    
    AssetManager.playMusic('music_menu');
  }

  void startGame() {
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.remove('PowerUpMenu'); // ✅ NEW
    
    // ✅ FIXED: Safe null-aware operations
    final currentScene = _gameScene;
    if (currentScene != null && children.contains(currentScene)) {
      remove(currentScene);
    }
    
    // Always create a fresh game scene
    _gameScene = GameScene();
    add(_gameScene!);
    currentState = GameState.playing;
    
    AssetManager.stopMusic();
    AssetManager.playMusic('music_game');
    
    print('✅ Game started with fresh scene');
  }

  // ✅ FIXED: All methods now properly handle null _gameScene
  int getFinalScore() {
    return _gameScene?.scoring.currentScore ?? 0;
  }

  int getFinalLevel() {
    return _gameScene?.scoring.level ?? 1;
  }

  int getFinalLinesCleared() {
    return _gameScene?.scoring.linesCleared ?? 0;
  }

  double getGridFillPercentage() {
    return _gameScene?.gridFillPercentage ?? 0.0;
  }

  // ✅ NEW: Enhanced game over methods with all features
  int getCoinsEarned() {
    return _gameScene?.getCoinsEarnedThisGame() ?? 0;
  }

  List<String> getUnlockedAchievements() {
    return _gameScene?.getRecentlyUnlockedAchievements() ?? [];
  }

  bool canUndoFromGameOver() {
    return _gameScene?.undoManager.canUndo ?? false;
  }

  int getRemainingUndos() {
    return _gameScene?.undoManager.remainingUndos ?? 0;
  }

  bool canUndoLastMove() {
    return _gameScene?.undoManager.canUndo ?? false;
  }

  void undoLastMove() {
    print('↩️ Attempting undo from game over...');
    
    final currentScene = _gameScene;
    if (currentScene != null && currentScene.undoManager.canUndo) {
      // Remove game over overlay
      overlays.remove('GameOver');
      
      // Perform undo
      final success = currentScene.performUndo();
      
      if (success) {
        // Return to playing state
        currentState = GameState.playing;
        print('✅ Undo successful - returned to playing state');
      } else {
        // If undo failed, show game over again
        overlays.add('GameOver');
        print('❌ Undo failed - showing game over again');
      }
    } else {
      print('❌ Cannot undo - no game scene or no undo available');
    }
  }

  void undoFromGameOver() {
    undoLastMove(); // Same functionality
  }

  void restartGame() {
    print('🔄 Restarting game from BoxHooksGame...');
    
    // Remove all overlays
    overlays.remove('GameOver');
    overlays.remove('PowerUpMenu');
    
    // ✅ FIXED: Safe null checking
    final currentScene = _gameScene;
    if (currentScene != null) {
      currentScene.restartGame();
    } else {
      // If no game scene exists, start a new game
      startGame();
      return;
    }
    
    // Update state
    currentState = GameState.playing;
    
    AssetManager.playSfx('sfx_click');
    
    print('✅ Game restarted successfully');
  }

  void returnToMainMenu() {
    print('🏠 Returning to main menu...');
    
    // Remove all overlays
    overlays.remove('GameOver');
    overlays.remove('PowerUpMenu');
    
    // ✅ FIXED: Safe removal of game scene
    final currentScene = _gameScene;
    if (currentScene != null && children.contains(currentScene)) {
      remove(currentScene);
      _gameScene = null; // Clear the reference
    }
    
    // Show main menu
    overlays.add('MainMenu');
    currentState = GameState.menu;
    
    AssetManager.stopMusic();
    AssetManager.playMusic('music_menu');
    AssetManager.playSfx('sfx_click');
  }

  // ✅ NEW: Enhanced monetization methods
  void watchAdForCoins() {
    final currentScene = _gameScene;
    if (currentScene != null) {
      currentScene.coinManager.watchAdForCoins();
    }
    print('📺 Watched ad for coins');
  }

  void openPowerUpStore() {
    print('🛒 Opening power-up store...');
    // TODO: Implement power-up store overlay
    AssetManager.playSfx('sfx_click');
  }

  // ✅ ENHANCED: Share score with achievement info
  void shareScore() {
    final score = getFinalScore();
    final level = getFinalLevel();
    final achievements = getUnlockedAchievements().length;
    
    print('📤 Sharing enhanced score: $score (Level $level, $achievements achievements)');
    
    final shareText = "I just scored $score points in Box Hooks! Level $level reached with $achievements achievements unlocked! 🎮🏆";
    print('Share text: $shareText');
    
    AssetManager.playSfx('sfx_click');
  }

  // ✅ NEW: Power-up system integration
  Map<PowerUpType, int> getPowerUpInventory() {
    return _gameScene?.getPowerUpInventory() ?? {};
  }

  void usePowerUp(PowerUpType type) {
    final currentScene = _gameScene;
    if (currentScene != null) {
      final success = currentScene.powerUpManager.activatePowerUp(type);
      if (success) {
        print('✅ Activated ${PowerUpManager.powerUps[type]!.name}');
        // For immediate effects, hide menu. For target effects, keep menu open until used
        if (type == PowerUpType.shuffle || type == PowerUpType.freeze) {
          overlays.remove('PowerUpMenu');
        }
      } else {
        print('❌ Cannot activate ${PowerUpManager.powerUps[type]!.name}');
      }
    }
  }

  void cancelPowerUp() {
    final currentScene = _gameScene;
    if (currentScene != null) {
      currentScene.powerUpManager.cancelActivePowerUp();
      overlays.remove('PowerUpMenu');
    }
  }

  bool purchasePowerUpWithCoins(PowerUpType type) {
    final currentScene = _gameScene;
    if (currentScene != null) {
      final success = currentScene.coinManager.purchasePowerUp(type, currentScene.powerUpManager);
      if (success) {
        print('✅ Purchased ${PowerUpManager.powerUps[type]!.name}');
        return true;
      } else {
        print('❌ Cannot afford ${PowerUpManager.powerUps[type]!.name}');
        return false;
      }
    }
    return false;
  }

  int getCurrentCoins() {
    return _gameScene?.getCurrentCoins() ?? 0;
  }

  bool hasPowerUp(String powerUpType) {
    final currentScene = _gameScene;
    if (currentScene != null) {
      PowerUpType? type;
      switch (powerUpType.toLowerCase()) {
        case 'hammer':
          type = PowerUpType.hammer;
          break;
        case 'bomb':
          type = PowerUpType.bomb;
          break;
        case 'shuffle':
          type = PowerUpType.shuffle;
          break;
        case 'hint':
          type = PowerUpType.hint;
          break;
        case 'freeze':
          type = PowerUpType.freeze;
          break;
      }
      
      if (type != null) {
        return currentScene.hasPowerUp(type);
      }
    }
    return false;
  }

  // ✅ FIXED: Safe undo testing
  void testUndo() {
    print('🧪 Testing undo...');
    final currentScene = _gameScene;
    if (currentScene != null) {
      final success = currentScene.performUndo();
      if (success) {
        print('✅ Undo test successful!');
      } else {
        print('❌ Undo test failed');
      }
    } else {
      print('❌ No game scene available for undo test');
    }
  }

  void claimDailyReward() {
    print('🎁 Daily reward claimed!');
    // ✅ NEW: Award coins through game scene if available
    final currentScene = _gameScene;
    if (currentScene != null) {
      currentScene.coinManager.claimDailyBonus();
    }
    AssetManager.playSfx('sfx_reward');
  }

  void openShop() {
    print('🛒 Opening shop...');
    AssetManager.playSfx('sfx_click');
  }

  void openSettings() {
    print('⚙️ Opening settings...');
    AssetManager.playSfx('sfx_click');
  }

  @override
  void onRemove() {
    // Stop all audio when game is removed
    AssetManager.stopMusic();
    super.onRemove();
  }

  void pauseGame() {
    if (currentState == GameState.playing) {
      currentState = GameState.paused;
      print('⏸️ Game paused');
    }
  }

  void resumeGame() {
    if (currentState == GameState.paused) {
      currentState = GameState.playing;
      print('▶️ Game resumed');
    }
  }

  void toggleMusic() {
    print('🎵 Music toggle requested');
    // TODO: Implement music toggle with settings persistence
  }

  void toggleSoundEffects() {
    print('🔊 SFX toggle requested');
    // TODO: Implement SFX toggle with settings persistence
  }

  // ✅ NEW: Debug methods for testing
  void printGameStatus() {
    print('🎮 GAME STATUS:');
    print('   State: $currentState');
    print('   Scene: ${_gameScene != null ? "Active" : "None"}');
    print('   Score: ${getFinalScore()}');
    print('   Coins: ${getCurrentCoins()}');
    print('   Achievements: ${getUnlockedAchievements().length}');
  }

  void grantTestCoins(int amount) {
    final currentScene = _gameScene;
    if (currentScene != null) {
      currentScene.coinManager.grantCoins(amount, 'test_grant');
      print('🎁 Granted $amount test coins');
    }
  }

  // ✅ NEW: Grant test power-ups for debugging
  void grantTestPowerUps() {
    final currentScene = _gameScene;
    if (currentScene != null) {
      currentScene.powerUpManager.addPowerUp(PowerUpType.hammer, 5);
      currentScene.powerUpManager.addPowerUp(PowerUpType.bomb, 3);
      currentScene.powerUpManager.addPowerUp(PowerUpType.shuffle, 5);
      currentScene.powerUpManager.addPowerUp(PowerUpType.hint, 10);
      currentScene.powerUpManager.addPowerUp(PowerUpType.freeze, 3);
      print('🎁 Granted test power-ups');
    }
  }
}
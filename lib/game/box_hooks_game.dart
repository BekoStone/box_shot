// ignore_for_file: avoid_print

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import '../services/asset_manager.dart';
import 'game_state.dart';
import 'components/game_scene.dart';

class BoxHooksGame extends FlameGame with DragCallbacks, TapCallbacks, HasCollisionDetection {
  GameState currentState = GameState.splash;

  // ✅ FIX: Make _gameScene nullable instead of late
  GameScene? _gameScene;

  @override
  Future<void> onLoad() async {
    await AssetManager.preloadAssets();
    // ✅ Don't initialize _gameScene here - do it when game starts
  }

  void showMainMenu() {
    overlays.remove('AnimatedSplash');
    overlays.add('MainMenu');
    currentState = GameState.menu;
  }

  void startGame() {
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    
    // ✅ FIX: Remove existing game scene if present
    if (_gameScene != null && children.contains(_gameScene!)) {
      remove(_gameScene!);
    }
    
    // ✅ FIX: Always create a fresh game scene
    _gameScene = GameScene();
    add(_gameScene!);
    currentState = GameState.playing;
    
    print('✅ Game started with fresh scene');
  }

  // ✅ NEW: Game Over Support Methods
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

  // ✅ NEW: Undo support
  bool canUndoLastMove() {
    return _gameScene?.undoManager.canUndo ?? false;
  }

  void undoLastMove() {
    print('↩️ Attempting undo from game over...');
    
    if (_gameScene != null && _gameScene!.undoManager.canUndo) {
      // Remove game over overlay
      overlays.remove('GameOver');
      
      // Perform undo
      final success = _gameScene!.performUndo();
      
      if (success) {
        // Return to playing state
        currentState = GameState.playing;
        print('✅ Undo successful - returned to playing state');
        print('🎮 Game state: ${currentState}');
        print('🔓 Game over flag: ${_gameScene!.isGameOver}');
      } else {
        // If undo failed, show game over again
        overlays.add('GameOver');
        print('❌ Undo failed - showing game over again');
      }
    } else {
      print('❌ Cannot undo - no game scene or no undo available');
    }
  }

  void restartGame() {
    print('🔄 Restarting game from BoxHooksGame...');
    
    // Remove game over overlay
    overlays.remove('GameOver');
    
    // ✅ FIX: Check if game scene exists before restarting
    if (_gameScene != null) {
      _gameScene!.restartGame();
    } else {
      // If no game scene exists, start a new game
      startGame();
      return;
    }
    
    // Update state
    currentState = GameState.playing;
    
    print('✅ Game restarted successfully');
  }

  void returnToMainMenu() {
    print('🏠 Returning to main menu...');
    
    // Remove game over overlay
    overlays.remove('GameOver');
    
    // Remove game scene
    if (_gameScene != null && children.contains(_gameScene!)) {
      remove(_gameScene!);
      _gameScene = null; // ✅ FIX: Clear the reference
    }
    
    // Show main menu
    overlays.add('MainMenu');
    currentState = GameState.menu;
  }

  void shareScore() {
    final score = getFinalScore();
    final level = getFinalLevel();
    
    print('📤 Sharing score: $score (Level $level)');
    
    // - Social media sharing
    // - Copy to clipboard
    // - Screenshot with score
    
    // For now, just print the share text
    final shareText = "I just scored $score points in Box Hooks! Can you beat my level $level record? 🎮";
    print('Share text: $shareText');
  }

  // ✅ NEW: Test undo functionality
  void testUndo() {
    if (_gameScene != null) {
      _gameScene!.onUndoButtonTapped();
    }
  }

  // ✅ Existing methods (unchanged)
  void claimDailyReward() {
    print('🎁 Daily reward claimed!');
  }

  void openShop() {
    print('🛒 Opening shop...');
  }

  void openSettings() {
    print('⚙️ Opening settings...');
  }
}
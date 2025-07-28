// File: lib/src/app.dart - ULTRA SIMPLE TEST

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/box_hooks_game.dart';
import '../ui/screens/main_menu.dart';
import '../ui/screens/animated_splash.dart';
import '../ui/overlays/enhanced_game_over_overlay.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final game = BoxHooksGame();

    return MaterialApp(
      title: 'Box Hooks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      home: GameWidget(
        game: game,
        overlayBuilderMap: {
          'AnimatedSplash': (context, _) => AnimatedSplashScreen(
                onFinish: () => game.showMainMenu(),
              ),
          
          'MainMenu': (context, _) => MainMenuScreen(
                onPlay: game.startGame,
                onReward: game.claimDailyReward,
                onShop: game.openShop,
                onSettings: game.openSettings,
              ),
          
          'GameOver': (context, _) => EnhancedGameOverOverlay(
                finalScore: game.getFinalScore(),
                level: game.getFinalLevel(),
                linesCleared: game.getFinalLinesCleared(),
                gridFillPercentage: game.getGridFillPercentage(),
                coinsEarned: game.getCoinsEarned(),
                achievementsUnlocked: game.getUnlockedAchievements(),
                canUndo: game.canUndoFromGameOver(),
                undoCount: game.getRemainingUndos(),
                onRestart: game.restartGame,
                onMainMenu: game.returnToMainMenu,
                onShare: game.shareScore,
                onUndo: game.canUndoFromGameOver() ? game.undoFromGameOver : null,
                onWatchAd: game.watchAdForCoins,
                onBuyPowerUps: game.openPowerUpStore,
              ),
          
          // ✅ ULTRA SIMPLE TEST - Just show big red text
          'PowerUpMenu': (context, _) => Container(
                color: Colors.black.withOpacity(0.9),
                child: const Center(
                  child: Text(
                    'POWER-UP MENU WORKS!\n\nTap anywhere to close',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        },
        initialActiveOverlays: const ['AnimatedSplash'],
      ),
    );
  }
}
// File: lib/src/app.dart

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/box_hooks_game.dart';
import '../ui/screens/main_menu.dart';
import '../ui/screens/animated_splash.dart';
import '../ui/overlays/game_over_overlay.dart'; // ✅ NEW: Import game over overlay

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final game = BoxHooksGame();

    return GameWidget(
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
        // ✅ NEW: Game Over Overlay
        'GameOver': (context, _) => GameOverOverlay(
              finalScore: game.getFinalScore(),
              level: game.getFinalLevel(),
              linesCleared: game.getFinalLinesCleared(),
              gridFillPercentage: game.getGridFillPercentage(),
              onRestart: () => game.restartGame(),
              onMainMenu: () => game.returnToMainMenu(),
              onShare: () => game.shareScore(),
            ),
      },
      initialActiveOverlays: const ['AnimatedSplash'],
    );
  }
}
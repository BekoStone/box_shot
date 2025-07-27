// File: lib/src/app.dart

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/box_hooks_game.dart';
import '../ui/screens/main_menu.dart';
import '../ui/screens/animated_splash.dart';
import '../ui/overlays/game_over_overlay.dart';

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
        fontFamily: 'Cairo', // Match the theme font
      ),
      home: GameWidget(
        game: game,
        overlayBuilderMap: {
          // ✅ Animated Splash Screen
          'AnimatedSplash': (context, _) => AnimatedSplashScreen(
                onFinish: () => game.showMainMenu(),
              ),
          
          // ✅ Main Menu Screen
          'MainMenu': (context, _) => MainMenuScreen(
                onPlay: game.startGame,
                onReward: game.claimDailyReward,
                onShop: game.openShop,
                onSettings: game.openSettings,
              ),
          
          // ✅ Game Over Overlay with complete functionality
          'GameOver': (context, _) => GameOverOverlay(
                finalScore: game.getFinalScore(),
                level: game.getFinalLevel(),
                linesCleared: game.getFinalLinesCleared(),
                gridFillPercentage: game.getGridFillPercentage(),
                onRestart: () => game.restartGame(),
                onMainMenu: () => game.returnToMainMenu(),
                onShare: () => game.shareScore(),
              ),
          
          // 'PauseMenu': (context, _) => PauseMenuOverlay(...),
          // 'Settings': (context, _) => SettingsOverlay(...),
          // 'Shop': (context, _) => ShopOverlay(...),
          // 'DailyReward': (context, _) => DailyRewardOverlay(...),
        },
        initialActiveOverlays: const ['AnimatedSplash'],
      ),
    );
  }
}
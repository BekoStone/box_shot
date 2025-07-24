// File: lib/ui/screens/main_menu.dart

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/assets.dart';

class MainMenuScreen extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onReward;
  final VoidCallback onShop;
  final VoidCallback onSettings;

  const MainMenuScreen({
    super.key,
    required this.onPlay,
    required this.onReward,
    required this.onShop,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          Assets.bgMainMenu,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("BOX HOOKS",
                  style: AppTheme.titleStyle.copyWith(fontSize: 42)),
              const SizedBox(height: 40),
              MenuButton(text: "PLAY", onPressed: onPlay),
              const SizedBox(height: 20),
              MenuButton(text: "DAILY REWARD", onPressed: onReward),
              const SizedBox(height: 20),
              MenuButton(text: "SHOP", onPressed: onShop),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
          ),
        )
      ],
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
        backgroundColor: const Color.fromARGB(255, 28, 150, 215),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }
}

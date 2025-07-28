// File: lib/game/components/game_ui_component.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../managers/power_up_manager.dart';

class GameUIComponent extends PositionComponent with HasGameRef<BoxHooksGame>, TapCallbacks {
  late RectangleComponent powerUpButton;
  late TextComponent powerUpButtonText;
  bool _powerUpMenuVisible = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _createPowerUpButton();
  }

  void _createPowerUpButton() {
    final screenSize = gameRef.size;
    
    // Power-up button background
    powerUpButton = RectangleComponent(
      position: Vector2(screenSize.x - 100, 150),
      size: Vector2(80, 40),
      paint: Paint()
        ..color = Colors.purple.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );
    
    // Power-up button text
    powerUpButtonText = TextComponent(
      text: '🔥 POWER',
      position: Vector2(screenSize.x - 60, 170),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    add(powerUpButton);
    add(powerUpButtonText);
  }

  @override
  bool onTapUp(TapUpEvent event) {
    final buttonRect = Rect.fromLTWH(
      powerUpButton.position.x,
      powerUpButton.position.y,
      powerUpButton.size.x,
      powerUpButton.size.y,
    );
    
    if (buttonRect.contains(event.localPosition.toOffset())) {
      _togglePowerUpMenu();
      return true;
    }
    
    return false;
  }

  void _togglePowerUpMenu() {
    if (_powerUpMenuVisible) {
      gameRef.overlays.remove('PowerUpMenu');
      _powerUpMenuVisible = false;
    } else {
      gameRef.overlays.add('PowerUpMenu');
      _powerUpMenuVisible = true;
    }
  }

  void hidePowerUpMenu() {
    if (_powerUpMenuVisible) {
      gameRef.overlays.remove('PowerUpMenu');
      _powerUpMenuVisible = false;
    }
  }
}
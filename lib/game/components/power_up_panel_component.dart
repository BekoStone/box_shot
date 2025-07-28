// File: lib/game/components/power_up_panel_component.dart - NEW FILE

import 'package:box_shot/game/components/game_scene.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../managers/power_up_manager.dart';
import '../../services/asset_manager.dart';

class PowerUpPanelComponent extends PositionComponent with HasGameRef<BoxHooksGame>, TapCallbacks {
  static const double panelWidth = 80;
  static const double buttonHeight = 70;
  static const double buttonSpacing = 10;
  
  final Map<PowerUpType, PowerUpButtonComponent> _powerUpButtons = {};
  late TextComponent _coinDisplay;
  late RectangleComponent _panelBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    size = Vector2(panelWidth, gameRef.size.y);
    position = Vector2(gameRef.size.x - panelWidth - 10, 0); // Right side of screen
    
    _createPanelBackground();
    _createCoinDisplay();
    _createPowerUpButtons();
  }
void clearInstructions() {
    // Implement logic to clear instructions or leave empty if not needed
    children.whereType<TextComponent>().forEach((text) {
      if (text.text.contains('Tap grid to use')) {
        text.removeFromParent();
      }
    });
  }
  void _createPanelBackground() {
    _panelBackground = RectangleComponent(
      size: Vector2(panelWidth, gameRef.size.y),
      paint: Paint()
        ..color = Colors.black.withAlpha(179)

        ..style = PaintingStyle.fill,
    );
    
    final border = RectangleComponent(
      size: Vector2(panelWidth, gameRef.size.y),
      paint: Paint()
        ..color = Colors.white.withAlpha(77)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    add(_panelBackground);
    add(border);
  }

  void _createCoinDisplay() {
    _coinDisplay = TextComponent(
      text: '💰 0',
      position: Vector2(panelWidth / 2, 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_coinDisplay);
  }

  void _createPowerUpButtons() {
    double yPosition = 60; // Start below coin display
    
    for (final entry in PowerUpManager.powerUps.entries) {
      final type = entry.key;
      final data = entry.value;
      
      final button = PowerUpButtonComponent(
        type: type,
        data: data,
        position: Vector2(panelWidth / 2, yPosition),
        onPressed: () => _onPowerUpPressed(type),
        getCount: () => _getPowerUpCount(type),
        isEnabled: () => _isPowerUpEnabled(type),
      );
      
      _powerUpButtons[type] = button;
      add(button);
      
      yPosition += buttonHeight + buttonSpacing;
    }
  }

  void _onPowerUpPressed(PowerUpType type) {
    print('🔥 Power-up pressed: ${PowerUpManager.powerUps[type]!.name}');
    
    // Get the game scene to activate power-up
    final gameScene = gameRef.children.whereType<GameScene>().firstOrNull;
    if (gameScene != null) {
      final success = gameScene.powerUpManager.activatePowerUp(type);
      if (success) {
        AssetManager.playSfx('sfx_click');
        _updateDisplay(); // Update button states
        
        // Show instruction if it's a target-based power-up
        if (type == PowerUpType.hammer || type == PowerUpType.bomb || type == PowerUpType.hint) {
          _showTargetInstruction(type);
        }
      } else {
        AssetManager.playSfx('sfx_error');
      }
    }
  }

  void _showTargetInstruction(PowerUpType type) {
    final instruction = TextComponent(
      text: 'Tap grid to use ${PowerUpManager.powerUps[type]!.name}',
      position: Vector2(panelWidth / 2, gameRef.size.y - 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    add(instruction);
    
    // Remove instruction after 3 seconds
    instruction.add(RemoveEffect(delay: 3.0));
  }

  int _getPowerUpCount(PowerUpType type) {
    final gameScene = gameRef.children.whereType<GameScene>().firstOrNull;
    return gameScene?.powerUpManager.getPowerUpCount(type) ?? 0;
  }

  bool _isPowerUpEnabled(PowerUpType type) {
    return _getPowerUpCount(type) > 0;
  }

  void updateDisplay() {
    _updateDisplay();
  }

  void _updateDisplay() {
    // Update coin display
    final gameScene = gameRef.children.whereType<GameScene>().firstOrNull;
    final coins = gameScene?.getCurrentCoins() ?? 0;
    _coinDisplay.text = '💰 $coins';
    
    // Update all power-up buttons
    for (final button in _powerUpButtons.values) {
      button.updateAppearance();
    }
  }
}

class PowerUpButtonComponent extends PositionComponent with TapCallbacks {
  final PowerUpType type;
  final PowerUpData data;
  final VoidCallback onPressed;
  final int Function() getCount;
  final bool Function() isEnabled;
  
  late RectangleComponent _background;
  late TextComponent _iconText;
  late TextComponent _countText;
  late TextComponent _nameText;
  bool _isPressed = false;

  PowerUpButtonComponent({
    required this.type,
    required this.data,
    required this.onPressed,
    required this.getCount,
    required this.isEnabled,
    required Vector2 position,
  }) {
    this.position = position;
    size = Vector2(PowerUpPanelComponent.panelWidth - 10, PowerUpPanelComponent.buttonHeight);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = data.color.withAlpha(77)
        ..style = PaintingStyle.fill,
    );
    
    _iconText = TextComponent(
      text: data.icon,
      position: Vector2(size.x / 2, 15),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
    );
    
    _nameText = TextComponent(
      text: data.name.toUpperCase(),
      position: Vector2(size.x / 2, 35),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    _countText = TextComponent(
      text: '0',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    add(_background);
    add(_iconText);
    add(_nameText);
    add(_countText);
    
    updateAppearance();
  }

  void updateAppearance() {
    final count = getCount();
    final enabled = isEnabled();
    
    _countText.text = count.toString();
    
    // Update background color based on state
    if (_isPressed && enabled) {
      _background.paint.color = data.color.withAlpha(204);
    } else if (enabled) {
      _background.paint.color = data.color.withAlpha(128);
    } else {
      _background.paint.color = Colors.grey.withAlpha(77);
    }
    
    // Update text colors
    final textColor = enabled ? Colors.white : Colors.grey.shade600;
    _nameText.textRenderer = TextPaint(
      style: TextStyle(
        color: textColor,
        fontSize: 8,
        fontWeight: FontWeight.bold,
      ),
    );
    
    _countText.textRenderer = TextPaint(
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey.shade600,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (!isEnabled()) return false;
    
    _isPressed = true;
    updateAppearance();
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (!isEnabled()) return false;
    
    _isPressed = false;
    updateAppearance();
    onPressed();
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    updateAppearance();
    return true;
  }
}
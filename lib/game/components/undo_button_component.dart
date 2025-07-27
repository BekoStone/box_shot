// File: lib/game/components/undo_button_component.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class UndoButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  final String Function() getText;
  final bool Function() isEnabled;
  
  late RectangleComponent background;
  late TextComponent label;
  bool _isPressed = false;

  UndoButtonComponent({
    required this.onPressed,
    required this.getText,
    required this.isEnabled,
    required Vector2 position,
  }) {
    this.position = position;
    size = Vector2(120, 40);
  }

  @override
  Future<void> onLoad() async {
    // Background
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = isEnabled() ? Colors.green.withOpacity(0.8) : Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );
    
    // Border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Label
    label = TextComponent(
      text: getText(),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: isEnabled() ? Colors.white : Colors.grey.shade400,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    add(background);
    add(border);
    add(label);
    
    updateAppearance();
  }

  void updateAppearance() {
    final enabled = isEnabled();
    
    // Update background color
    background.paint.color = enabled 
        ? (_isPressed ? Colors.green.shade700 : Colors.green.withOpacity(0.8))
        : Colors.grey.withOpacity(0.5);
    
    // Update text color
    label.textRenderer = TextPaint(
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey.shade400,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    
    // Update text
    label.text = getText();
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
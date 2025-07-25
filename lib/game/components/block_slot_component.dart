import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BlockSlotComponent extends PositionComponent {
  static const double slotWidth = 90;
  static const double slotHeight = 90;

  final int index;

  BlockSlotComponent({required this.index}) {
    size = Vector2(slotWidth, slotHeight);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey.withAlpha(51),
    );
    add(background);
  }
}

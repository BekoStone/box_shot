import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import 'game_scene.dart';

class BlockComponent extends PositionComponent
    with HasGameRef<BoxHooksGame>, DragCallbacks {
  static const double cellSize = 36;
  static const double spacing = 3;

  final List<List<int>> shape;
  bool isLocked = false;
  late Vector2 originalPosition;

  BlockComponent({required this.shape}) {
    final width = shape[0].length;
    final height = shape.length;

    size = Vector2(
      width * (cellSize + spacing) - spacing,
      height * (cellSize + spacing) - spacing,
    );

    priority = 1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    originalPosition = position.clone();

    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          final square = RectangleComponent(
            position: Vector2(
              col * (cellSize + spacing),
              row * (cellSize + spacing),
            ),
            size: Vector2(cellSize, cellSize),
            paint: Paint()..color = Colors.deepPurpleAccent,
          );
          add(square);
        }
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isLocked) return;
    position += event.localDelta;
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isLocked) return; // ✅ FIX: Prevent drag if locked
    
    final scene = gameRef.children.whereType<GameScene>().first;

    // ✅ IMPROVED: Use new precise snap position calculation
    final snapPosition = scene.getSnapPosition(absolutePosition);

    // Check collision with other active blocks
    for (final other in scene.activeBlocks) {
      if (other != this && toRect().overlaps(other.toRect())) {
        position = originalPosition.clone();
        return;
      }
    }

    // Check if block can be placed at snap position
    if (!scene.canPlaceBlock(this, snapPosition)) {
      position = originalPosition.clone();
      return;
    }

    // ✅ IMPROVED: Precise positioning relative to scene
    position = snapPosition - scene.position;
    isLocked = true;

    // Mark grid cells as occupied
    scene.markBlockOccupied(this, snapPosition);
    scene.activeBlocks.remove(this);

    // ✅ FIX: Update original position to prevent visual duplication
    originalPosition = position.clone();

    // Spawn new blocks if all are placed
    if (scene.activeBlocks.isEmpty) {
      scene.spawnThreeBlocks();
    }

    super.onDragEnd(event);
  }

  // ✅ NEW: Reset to original position (for undo)
  void resetToOriginal() {
    position = originalPosition.clone();
    isLocked = false;
  }

  // ✅ NEW: Update original position (when block spawns)
  void updateOriginalPosition(Vector2 newPosition) {
    originalPosition = newPosition.clone();
    position = newPosition.clone();
  }
}
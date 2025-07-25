import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import 'game_scene.dart';

class BlockComponent extends PositionComponent
    with HasGameRef<BoxHooksGame>, DragCallbacks {
  static const double cellSize = 36; // ✅ كان 28
  static const double spacing = 3;   // ✅ كان 2

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
    final scene = gameRef.children.whereType<GameScene>().first;
    final grid = scene.gridPositions;

    Vector2 closest = grid[0][0];
    double minDist = double.infinity;

    for (final row in grid) {
      for (final cell in row) {
        final dist = absolutePosition.distanceTo(cell);
        if (dist < minDist) {
          minDist = dist;
          closest = cell;
        }
      }
    }

    for (final other in scene.activeBlocks) {
      if (other != this && toRect().overlaps(other.toRect())) {
        position = originalPosition.clone();
        return;
      }
    }

    if (!scene.canPlaceBlock(this, closest)) {
      position = originalPosition.clone();
      return;
    }

    position = closest - scene.position;
    isLocked = true;

    scene.markBlockOccupied(this, closest);
    scene.activeBlocks.remove(this);

    if (scene.activeBlocks.isEmpty) {
      scene.spawnThreeBlocks();
    }

    super.onDragEnd(event);
  }
}
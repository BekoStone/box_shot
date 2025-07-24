// ✅ File: lib/game/components/game_scene.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../factory/shape_factory.dart';
import 'block_component.dart';

class GameScene extends PositionComponent with HasGameRef<BoxHooksGame> {
  static const int gridSize = 8;
  static const double cellSize = 28;
  static const double spacing = 2;

  late List<List<Vector2>> gridPositions;
  late List<List<bool>> occupiedGrid;

  final List<BlockComponent> activeBlocks = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gridPositions = List.generate(
      gridSize,
      (_) => List.filled(gridSize, Vector2.zero()),
    );

    occupiedGrid = List.generate(
      gridSize,
      (_) => List.filled(gridSize, false),
    );

    final screenSize = gameRef.size;
    final totalSize = (cellSize * gridSize) + (spacing * (gridSize - 1));
    final startX = (screenSize.x - totalSize) / 2;
    final startY = (screenSize.y - totalSize) / 2;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final x = startX + col * (cellSize + spacing);
        final y = startY + row * (cellSize + spacing);

        gridPositions[row][col] = Vector2(x, y);

        final cell = RectangleComponent(
          position: Vector2(x, y),
          size: Vector2(cellSize, cellSize),
          paint: Paint()
            ..color = Colors.grey.shade600
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );

        add(cell);
      }
    }

    spawnThreeBlocks();
  }

  void spawnThreeBlocks() {
    activeBlocks.clear();
    const spacingBetween = 40.0;
    const bottomPadding = 60.0; // ✅ رفع البلوكات فوق الخط السفلي
    final screenWidth = gameRef.size.x;

    final List<BlockComponent> blocks = List.generate(
      3,
      (_) => ShapeFactory.generateRandomShape(),
    );

    final maxHeight = blocks.map((b) => b.size.y).reduce((a, b) => a > b ? a : b);
    final totalWidth = blocks.fold<double>(
      0,
      (sum, b) => sum + b.size.x,
    ) + spacingBetween * 2;

    final startX = (screenWidth - totalWidth) / 2;
    double currentX = startX;

    for (final block in blocks) {
      final offsetY = maxHeight - block.size.y;
      block.position = Vector2(
        currentX,
        gameRef.size.y - maxHeight - bottomPadding + offsetY,
      );
      currentX += block.size.x + spacingBetween;

      activeBlocks.add(block);
      add(block);
    }
  }

  bool canPlaceBlock(BlockComponent block, Vector2 snapPosition) {
    final local = snapPosition - position;

    // ✅ تأكد إن التسكين داخل منطقة الجدول
    if (snapPosition.y > gridPositions[gridSize - 1][0].y + cellSize) {
      return false;
    }

    for (int row = 0; row < block.shape.length; row++) {
      for (int col = 0; col < block.shape[row].length; col++) {
        if (block.shape[row][col] == 0) continue;

        final x = local.x + col * (cellSize + spacing);
        final y = local.y + row * (cellSize + spacing);

        int nearestRow = -1, nearestCol = -1;
        double minDist = double.infinity;

        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            final dist = Vector2(x, y).distanceTo(gridPositions[r][c]);
            if (dist < minDist) {
              minDist = dist;
              nearestRow = r;
              nearestCol = c;
            }
          }
        }

        if (nearestRow < 0 || nearestCol < 0 || nearestRow >= gridSize || nearestCol >= gridSize) {
          return false;
        }

        if (occupiedGrid[nearestRow][nearestCol]) {
          return false;
        }
      }
    }

    return true;
  }

  void markBlockOccupied(BlockComponent block, Vector2 snapPosition) {
    final local = snapPosition - position;

    for (int row = 0; row < block.shape.length; row++) {
      for (int col = 0; col < block.shape[row].length; col++) {
        if (block.shape[row][col] == 0) continue;

        final x = local.x + col * (cellSize + spacing);
        final y = local.y + row * (cellSize + spacing);

        int nearestRow = -1, nearestCol = -1;
        double minDist = double.infinity;

        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            final dist = Vector2(x, y).distanceTo(gridPositions[r][c]);
            if (dist < minDist) {
              minDist = dist;
              nearestRow = r;
              nearestCol = c;
            }
          }
        }

        if (nearestRow >= 0 && nearestCol >= 0) {
          occupiedGrid[nearestRow][nearestCol] = true;
        }
      }
    }
  }
}




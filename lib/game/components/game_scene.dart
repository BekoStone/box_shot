import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../factory/shape_factory.dart';
import 'block_component.dart';
import 'block_slot_component.dart' as slot;

class GameScene extends PositionComponent with HasGameRef<BoxHooksGame> {
  static const int gridSize = 8;
  static const double cellSize = 36;
  static const double spacing = 2;
  static const int extendedGridSize = gridSize + 2;

  late List<List<Vector2>> gridPositions;
  late List<List<bool>> occupiedGrid;

  final List<BlockComponent> activeBlocks = [];
  final List<slot.BlockSlotComponent> slots = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gridPositions = List.generate(
      extendedGridSize,
      (_) => List.filled(extendedGridSize, Vector2.zero()),
    );

    occupiedGrid = List.generate(
      extendedGridSize,
      (r) => List.generate(
        extendedGridSize,
        (c) =>
            r == 0 || c == 0 || r == extendedGridSize - 1 || c == extendedGridSize - 1,
      ),
    );

    final screenSize = gameRef.size;
    final totalSize = (cellSize * gridSize) + (spacing * (gridSize - 1));
    final startX = (screenSize.x - totalSize) / 2 - (cellSize + spacing);
    final startY = (screenSize.y - totalSize) / 2 - (cellSize + spacing);

    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        final x = startX + col * (cellSize + spacing);
        final y = startY + row * (cellSize + spacing);

        gridPositions[row][col] = Vector2(x, y);

        if (row == 0 || col == 0 || row == extendedGridSize - 1 || col == extendedGridSize - 1) {
          continue;
        }

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

    _createSlots();
    spawnThreeBlocks();
  }

  void _createSlots() {
    const slotSpacing = 40.0;
    final screenWidth = gameRef.size.x;
    final centerY = gameRef.size.y - 200;
    final totalWidth = 3 * slot.BlockSlotComponent.slotWidth + 2 * slotSpacing;
    final startX = (screenWidth - totalWidth) / 2;

    for (int i = 0; i < 3; i++) {
      final x = startX + i * (slot.BlockSlotComponent.slotWidth + slotSpacing);
      final slotComponent = slot.BlockSlotComponent(index: i)
        ..position = Vector2(x, centerY);
      slots.add(slotComponent);
      add(slotComponent);
    }
  }

  void spawnThreeBlocks() {
    activeBlocks.clear();

    for (int i = 0; i < 3; i++) {
      final shape = ShapeFactory.generateRandomShape().shape;
      final block = BlockComponent(shape: shape);
      final slotComponent = slots[i];

      block.position = slotComponent.position.clone() +
          Vector2(
            (slot.BlockSlotComponent.slotWidth - block.size.x) / 2,
            (slot.BlockSlotComponent.slotHeight - block.size.y) / 2,
          );

      activeBlocks.add(block);
      add(block);
    }
  }

  bool canPlaceBlock(BlockComponent block, Vector2 snapPosition) {
    final local = snapPosition - position;

    for (int row = 0; row < block.shape.length; row++) {
      for (int col = 0; col < block.shape[row].length; col++) {
        if (block.shape[row][col] == 0) continue;

        final x = local.x + col * (cellSize + spacing);
        final y = local.y + row * (cellSize + spacing);

        int nearestRow = -1, nearestCol = -1;
        double minDist = double.infinity;

        for (int r = 0; r < extendedGridSize; r++) {
          for (int c = 0; c < extendedGridSize; c++) {
            final dist = Vector2(x, y).distanceTo(gridPositions[r][c]);
            if (dist < minDist) {
              minDist = dist;
              nearestRow = r;
              nearestCol = c;
            }
          }
        }

        if (nearestRow <= 0 || nearestCol <= 0 ||
            nearestRow >= extendedGridSize - 1 || nearestCol >= extendedGridSize - 1) {
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

        for (int r = 0; r < extendedGridSize; r++) {
          for (int c = 0; c < extendedGridSize; c++) {
            final dist = Vector2(x, y).distanceTo(gridPositions[r][c]);
            if (dist < minDist) {
              minDist = dist;
              nearestRow = r;
              nearestCol = c;
            }
          }
        }

        if (nearestRow > 0 &&
            nearestCol > 0 &&
            nearestRow < extendedGridSize - 1 &&
            nearestCol < extendedGridSize - 1) {
          occupiedGrid[nearestRow][nearestCol] = true;
        }
      }
    }
  }
}




// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../factory/shape_factory.dart';
import 'block_component.dart';
import 'block_slot_component.dart' as slot;

class GameScene extends PositionComponent with HasGameRef<BoxHooksGame> {
  static const int gridSize = 8;
  static const double cellSize = 36;
  static const double spacing = 3;
  static const int extendedGridSize = gridSize + 2;

  late List<List<Vector2>> gridPositions;
  late List<List<bool>> occupiedGrid;
  late List<List<Component?>> visualGrid;
  
  // ✅ NEW: Grid calculation properties for precise mapping
  late double _gridStartX;
  late double _gridStartY;
  late double _cellStep; // cellSize + spacing

  final List<BlockComponent> activeBlocks = [];
  final List<slot.BlockSlotComponent> slots = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // ✅ IMPROVED: Calculate grid parameters once
    _cellStep = cellSize + spacing;
    final screenSize = gameRef.size;
    final totalSize = (cellSize * gridSize) + (spacing * (gridSize - 1));
    _gridStartX = (screenSize.x - totalSize) / 2 - _cellStep;
    _gridStartY = (screenSize.y - totalSize) / 2 - _cellStep;

    _initializeGrids();
    _createGridVisuals();
    _createSlots();
    spawnThreeBlocks();
  }

  // ✅ NEW: Track placed block components instead of creating duplicates
  late List<List<BlockComponent?>> placedBlocks;

  void _initializeGrids() {
    gridPositions = List.generate(
      extendedGridSize,
      (_) => List.filled(extendedGridSize, Vector2.zero()),
    );

    occupiedGrid = List.generate(
      extendedGridSize,
      (r) => List.generate(
        extendedGridSize,
        (c) => r == 0 || c == 0 || r == extendedGridSize - 1 || c == extendedGridSize - 1,
      ),
    );

    // ✅ Track actual placed block components instead of visual grid
    placedBlocks = List.generate(
      extendedGridSize,
      (_) => List.filled(extendedGridSize, null),
    );

    visualGrid = List.generate(
      extendedGridSize,
      (_) => List.filled(extendedGridSize, null),
    );

    // Fill grid positions
    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        gridPositions[row][col] = Vector2(
          _gridStartX + col * _cellStep,
          _gridStartY + row * _cellStep,
        );
      }
    }
  }

  void _createGridVisuals() {
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final cell = RectangleComponent(
          position: gridPositions[row][col],
          size: Vector2(cellSize, cellSize),
          paint: Paint()
            ..color = Colors.grey.shade600
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        add(cell);
      }
    }
  }

  // ✅ NEW: Precise coordinate-to-grid conversion
  Vector2 _worldToGrid(Vector2 worldPos) {
    final relativeX = worldPos.x - _gridStartX;
    final relativeY = worldPos.y - _gridStartY;
    
    final col = (relativeX / _cellStep).round();
    final row = (relativeY / _cellStep).round();
    
    return Vector2(col.toDouble(), row.toDouble());
  }

  // ✅ NEW: Check if grid coordinates are valid
  bool _isValidGridPos(int row, int col) {
    return row > 0 && col > 0 && 
           row < extendedGridSize - 1 && 
           col < extendedGridSize - 1;
  }

  // ✅ NEW: Get snap position from world coordinates
  Vector2 getSnapPosition(Vector2 worldPos) {
    final gridCoord = _worldToGrid(worldPos);
    final row = gridCoord.y.toInt();
    final col = gridCoord.x.toInt();
    
    // Clamp to valid range
    final clampedRow = row.clamp(1, extendedGridSize - 2);
    final clampedCol = col.clamp(1, extendedGridSize - 2);
    
    return gridPositions[clampedRow][clampedCol];
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

  // ✅ IMPROVED: Precise block placement validation
  bool canPlaceBlock(BlockComponent block, Vector2 snapPosition) {
    final gridCoord = _worldToGrid(snapPosition);
    final baseRow = gridCoord.y.toInt();
    final baseCol = gridCoord.x.toInt();

    // Check each cell of the block shape
    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 0) continue;

        final gridRow = baseRow + shapeRow;
        final gridCol = baseCol + shapeCol;

        // Check bounds
        if (!_isValidGridPos(gridRow, gridCol)) {
          return false;
        }

        // Check if cell is occupied
        if (occupiedGrid[gridRow][gridCol]) {
          return false;
        }
      }
    }

    return true;
  }

  // ✅ FIXED: Track the actual placed block component
  void markBlockOccupied(BlockComponent block, Vector2 snapPosition) {
    final gridCoord = _worldToGrid(snapPosition);
    final baseRow = gridCoord.y.toInt();
    final baseCol = gridCoord.x.toInt();

    print('🎯 Marking block at grid ($baseRow, $baseCol)');

    // Mark each cell of the block shape as occupied
    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 0) continue;

        final gridRow = baseRow + shapeRow;
        final gridCol = baseCol + shapeCol;

        if (_isValidGridPos(gridRow, gridCol)) {
          occupiedGrid[gridRow][gridCol] = true;
          // ✅ Store reference to the actual placed block component
          placedBlocks[gridRow][gridCol] = block;
          
          print('📍 Marked cell ($gridRow, $gridCol) with block component');
        }
      }
    }

    checkForCompletedLines();
  }

  // ✅ IMPROVED: Optimized line detection with debug logging
  void checkForCompletedLines() {
    List<int> completedRows = [];
    List<int> completedCols = [];

    // Check rows (skip boundary rows 0 and extendedGridSize-1)
    for (int row = 1; row < extendedGridSize - 1; row++) {
      bool isRowComplete = true;
      int occupiedCount = 0;
      
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (occupiedGrid[row][col]) {
          occupiedCount++;
        } else {
          isRowComplete = false;
        }
      }
      
      // Debug: Print row status
      print('Row $row: $occupiedCount/${gridSize} occupied, complete: $isRowComplete');
      
      if (isRowComplete) {
        completedRows.add(row);
      }
    }

    // Check columns (skip boundary cols 0 and extendedGridSize-1)
    for (int col = 1; col < extendedGridSize - 1; col++) {
      bool isColComplete = true;
      int occupiedCount = 0;
      
      for (int row = 1; row < extendedGridSize - 1; row++) {
        if (occupiedGrid[row][col]) {
          occupiedCount++;
        } else {
          isColComplete = false;
        }
      }
      
      // Debug: Print column status
      print('Col $col: $occupiedCount/${gridSize} occupied, complete: $isColComplete');
      
      if (isColComplete) {
        completedCols.add(col);
      }
    }

    // Clear completed lines if any found
    if (completedRows.isNotEmpty || completedCols.isNotEmpty) {
      print('🎉 CLEARING LINES: Rows: $completedRows, Cols: $completedCols');
      clearLines(completedRows, completedCols);
    } else {
      print('No completed lines found');
    }
  }

  // ✅ FIXED: Remove actual placed block components
  void clearLines(List<int> rows, List<int> cols) {
    Set<BlockComponent> blocksToRemove = {};
    int clearedCellCount = 0;

    print('🧹 Starting line clear - Rows: $rows, Cols: $cols');

    // Mark cells for clearing and collect unique block components
    for (int row in rows) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (placedBlocks[row][col] != null) {
          blocksToRemove.add(placedBlocks[row][col]!);
          occupiedGrid[row][col] = false;
          placedBlocks[row][col] = null;
          clearedCellCount++;
          print('🎯 Marked cell ($row, $col) for clearing');
        }
      }
    }

    for (int col in cols) {
      for (int row = 1; row < extendedGridSize - 1; row++) {
        if (placedBlocks[row][col] != null) {
          blocksToRemove.add(placedBlocks[row][col]!);
          occupiedGrid[row][col] = false;
          placedBlocks[row][col] = null;
          clearedCellCount++;
          print('🎯 Marked cell ($row, $col) for clearing');
        }
      }
    }

    print('📦 Found ${blocksToRemove.length} unique block components to remove');
    print('🔍 Cleared $clearedCellCount individual cells');

    // ✅ Remove the actual block components
    for (BlockComponent block in blocksToRemove) {
      try {
        remove(block);
        print('🗑️ Removed block component successfully');
      } catch (e) {
        print('❌ Error removing block: $e');
      }
    }

    print('✅ Line clearing completed');

    // TODO: Add scoring logic here
    // final clearedCells = clearedCellCount;
    // _updateScore(rows.length, cols.length, clearedCells);
  }

  // ✅ NEW: Debug method to visualize grid mapping
  void debugGrid() {
    print('Grid Debug Info:');
    print('Start: ($_gridStartX, $_gridStartY)');
    print('Cell Step: $_cellStep');
    print('Extended Grid Size: $extendedGridSize');
    
    // Test a few coordinates
    final testPos = gridPositions[5][5];
    final mapped = _worldToGrid(testPos);
    print('Position $testPos maps to grid ($mapped)');
  }
}
// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../factory/shape_factory.dart';
import '../managers/scoring_manager.dart';
import '../managers/game_over_manager.dart';
import '../managers/undo_manager.dart';
import '../game_state.dart';
import '../../services/asset_manager.dart';
import 'block_component.dart';
import 'block_slot_component.dart' as slot;
import 'undo_button_component.dart';

class GameScene extends PositionComponent with HasGameRef<BoxHooksGame>, TapCallbacks {
  static const int gridSize = 8;
  static const double cellSize = 36;
  static const double spacing = 3;
  static const int extendedGridSize = gridSize + 2;

  // ✅ Make grid properties accessible for GameOverManager
  late List<List<Vector2>> gridPositions;
  late List<List<bool>> occupiedGrid;
  late List<List<Component?>> visualGrid;
  late List<List<BlockComponent?>> placedBlocks;
  
  // ✅ Grid calculation properties for precise mapping
  late double _gridStartX;
  late double _gridStartY;
  late double _cellStep;

  // ✅ NEW: Scoring system, game state, and undo system
  final ScoringManager scoring = ScoringManager();
  final UndoManager undoManager = UndoManager();
  late TextComponent scoreDisplay;
  late TextComponent levelDisplay;
  late TextComponent comboDisplay;
  late UndoButtonComponent undoButtonComponent;
  
  bool _gameOver = false;
  bool _gameOverProcessed = false;

  final List<BlockComponent> activeBlocks = [];
  final List<slot.BlockSlotComponent> slots = [];
  
  // ✅ NEW: Getters for external access
  List<BlockComponent> get activeBlocksList => activeBlocks;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Calculate grid parameters
    _cellStep = cellSize + spacing;
    final screenSize = gameRef.size;
    final totalSize = (cellSize * gridSize) + (spacing * (gridSize - 1));
    _gridStartX = (screenSize.x - totalSize) / 2 - _cellStep;
    _gridStartY = (screenSize.y - totalSize) / 2 - _cellStep;

    _initializeGrids();
    _createGridVisuals();
    _createUI();
    _createSlots();
    spawnThreeBlocks();
  }

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

  // ✅ Create UI elements with enhanced undo button
  void _createUI() {
    final screenSize = gameRef.size;
    
    // Score display
    scoreDisplay = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreDisplay);
    
    // Level display
    levelDisplay = TextComponent(
      text: 'Level: 1',
      position: Vector2(screenSize.x - 120, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(levelDisplay);
    
    // Combo display
    comboDisplay = TextComponent(
      text: '',
      position: Vector2(screenSize.x / 2 - 50, 100),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(comboDisplay);
    
    // ✅ Enhanced undo button component (top-right, below level)
    undoButtonComponent = UndoButtonComponent(
      position: Vector2(screenSize.x - 140, 85),
      onPressed: onUndoButtonTapped,
      getText: () {
        final remaining = undoManager.remainingUndos;
        return remaining > 0 ? '↩️ UNDO ($remaining)' : '↩️ NO UNDO';
      },
      isEnabled: () => undoManager.canUndo,
    );
    add(undoButtonComponent);
    
    print('✅ Enhanced undo button component added at top-right');
  }

  // ✅ Update UI displays
  void _updateUI() {
    final data = scoring.getScoreData();
    
    scoreDisplay.text = 'Score: ${data['formattedScore']}';
    levelDisplay.text = 'Level: ${data['level']}';
    
    if (data['combo'] > 0) {
      comboDisplay.text = 'Combo x${data['combo']}';
      if (data['streak'] > 0) {
        comboDisplay.text += ' • Streak x${data['streak']}';
      }
    } else {
      comboDisplay.text = '';
    }
    
    // ✅ Update undo button appearance
    undoButtonComponent.updateAppearance();
  }

  Vector2 _worldToGrid(Vector2 worldPos) {
    final relativeX = worldPos.x - _gridStartX;
    final relativeY = worldPos.y - _gridStartY;
    
    final col = (relativeX / _cellStep).round();
    final row = (relativeY / _cellStep).round();
    
    return Vector2(col.toDouble(), row.toDouble());
  }

  bool _isValidGridPos(int row, int col) {
    return row > 0 && col > 0 && 
           row < extendedGridSize - 1 && 
           col < extendedGridSize - 1;
  }

  Vector2 getSnapPosition(Vector2 worldPos) {
    final gridCoord = _worldToGrid(worldPos);
    final row = gridCoord.y.toInt();
    final col = gridCoord.x.toInt();
    
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
    
    _checkGameOver();
  }

  bool canPlaceBlock(BlockComponent block, Vector2 snapPosition) {
    final gridCoord = _worldToGrid(snapPosition);
    final baseRow = gridCoord.y.toInt();
    final baseCol = gridCoord.x.toInt();

    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 0) continue;

        final gridRow = baseRow + shapeRow;
        final gridCol = baseCol + shapeCol;

        if (!_isValidGridPos(gridRow, gridCol)) {
          return false;
        }

        if (occupiedGrid[gridRow][gridCol]) {
          return false;
        }
      }
    }

    return true;
  }

  void markBlockOccupied(BlockComponent block, Vector2 snapPosition) {
    if (_gameOver) return;
    
    _saveCurrentState();
    
    final gridCoord = _worldToGrid(snapPosition);
    final baseRow = gridCoord.y.toInt();
    final baseCol = gridCoord.x.toInt();
    
    int cellsPlaced = 0;

    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 0) continue;

        final gridRow = baseRow + shapeRow;
        final gridCol = baseCol + shapeCol;

        if (_isValidGridPos(gridRow, gridCol)) {
          occupiedGrid[gridRow][gridCol] = true;
          placedBlocks[gridRow][gridCol] = block;
          cellsPlaced++;
        }
      }
    }

    scoring.awardBlockPlacement(cellsPlaced);
    _updateUI();

    checkForCompletedLines();
    _checkGameOver();
  }

  void checkForCompletedLines() {
    List<int> completedRows = [];
    List<int> completedCols = [];

    for (int row = 1; row < extendedGridSize - 1; row++) {
      bool isRowComplete = true;
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (!occupiedGrid[row][col]) {
          isRowComplete = false;
          break;
        }
      }
      if (isRowComplete) {
        completedRows.add(row);
      }
    }

    for (int col = 1; col < extendedGridSize - 1; col++) {
      bool isColComplete = true;
      for (int row = 1; row < extendedGridSize - 1; row++) {
        if (!occupiedGrid[row][col]) {
          isColComplete = false;
          break;
        }
      }
      if (isColComplete) {
        completedCols.add(col);
      }
    }

    if (completedRows.isNotEmpty || completedCols.isNotEmpty) {
      clearLines(completedRows, completedCols);
    } else {
      scoring.resetCombo();
      _updateUI();
    }
  }

  void clearLines(List<int> rows, List<int> cols) {
    Set<Vector2> cellsToRemove = {};
    Map<BlockComponent, Set<Vector2>> affectedBlocks = {};

    for (int row in rows) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        cellsToRemove.add(Vector2(col.toDouble(), row.toDouble()));
      }
    }

    for (int col in cols) {
      for (int row = 1; row < extendedGridSize - 1; row++) {
        cellsToRemove.add(Vector2(col.toDouble(), row.toDouble()));
      }
    }

    for (final cell in cellsToRemove) {
      final row = cell.y.toInt();
      final col = cell.x.toInt();
      
      if (placedBlocks[row][col] != null) {
        final block = placedBlocks[row][col]!;
        
        if (!affectedBlocks.containsKey(block)) {
          affectedBlocks[block] = {};
        }
        affectedBlocks[block]!.add(cell);
        
        occupiedGrid[row][col] = false;
        placedBlocks[row][col] = null;
      }
    }

    for (final entry in affectedBlocks.entries) {
      final block = entry.key;
      final clearedCells = entry.value;
      
      final remainingCells = _findRemainingCells(block, clearedCells);
      
      if (remainingCells.isNotEmpty) {
        _createBlockFromCells(remainingCells);
      }
      
      remove(block);
    }

    final totalCellsCleared = cellsToRemove.length;
    final isPerfectClear = _checkPerfectClear();
    
    scoring.awardLineClear(
      linesCleared: rows.length,
      columnsCleared: cols.length,
      totalCellsCleared: totalCellsCleared,
      isPerfectClear: isPerfectClear,
    );
    
    _updateUI();
  }

  bool _checkPerfectClear() {
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (occupiedGrid[row][col]) {
          return false;
        }
      }
    }
    return true;
  }

  Set<Vector2> _findRemainingCells(BlockComponent block, Set<Vector2> clearedCells) {
    Set<Vector2> remainingCells = {};
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (placedBlocks[row][col] == block) {
          final cellPos = Vector2(col.toDouble(), row.toDouble());
          
          if (!clearedCells.contains(cellPos)) {
            remainingCells.add(cellPos);
          }
        }
      }
    }
    
    return remainingCells;
  }

  void _createBlockFromCells(Set<Vector2> cells) {
    for (final cell in cells) {
      final row = cell.y.toInt();
      final col = cell.x.toInt();
      
      final newBlock = BlockComponent(shape: [[1]]);
      newBlock.position = gridPositions[row][col];
      newBlock.isLocked = true;
      
      add(newBlock);
      
      occupiedGrid[row][col] = true;
      placedBlocks[row][col] = newBlock;
    }
  }

  void _checkGameOver() {
    if (_gameOver || _gameOverProcessed) return;
    
    final isGameOver = GameOverManager.isGameOver(this);
    
    if (isGameOver) {
      _gameOver = true;
      _handleGameOver();
    } else {
      final isInDanger = GameOverManager.isGameInDanger(this);
      if (isInDanger) {
        print('⚠️ WARNING: Very few moves remaining!');
        _showDangerWarning();
      }
    }
  }
  
  void _handleGameOver() {
    if (_gameOverProcessed) return;
    _gameOverProcessed = true;
    
    print('🎮 GAME OVER!');
    
    GameOverManager.printGameAnalysis(this);
    
    final finalScore = scoring.currentScore;
    final level = scoring.level;
    
    print('🏆 Final Score: $finalScore');
    print('📊 Final Level: $level');
    
    for (final block in activeBlocks) {
      block.isLocked = true;
    }
    
    _showGameOverScreen();
  }
  
  void _showDangerWarning() {
    print('⚠️ Few moves remaining - plan carefully!');
  }
  
  void _showGameOverScreen() {
    print('💀 Showing game over screen...');
    
    final finalScore = scoring.currentScore;
    final level = scoring.level;
    final linesCleared = scoring.linesCleared;
    final fillPercentage = GameOverManager.getGridFillPercentage(this);
    
    gameRef.overlays.removeAll(['MainMenu', 'AnimatedSplash']);
    gameRef.overlays.add('GameOver');
    gameRef.currentState = GameState.gameOver;
    
    print('✅ Game over overlay should now be visible');
  }
  
  void restartGame() {
    print('🔄 Restarting game...');
    
    _gameOver = false;
    _gameOverProcessed = false;
    
    undoManager.resetForNewGame();
    
    final componentsToRemove = <Component>[];
    
    for (final child in children) {
      if (child is BlockComponent) {
        componentsToRemove.add(child);
      }
      if (child is RectangleComponent && 
          child.size.x == cellSize && 
          child.size.y == cellSize &&
          child.paint.color == Colors.deepPurpleAccent) {
        componentsToRemove.add(child);
      }
    }
    
    for (final component in componentsToRemove) {
      remove(component);
    }
    
    print('🗑️ Removed ${componentsToRemove.length} block components (kept grid lines)');
    
    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        if (row == 0 || col == 0 || row == extendedGridSize - 1 || col == extendedGridSize - 1) {
          occupiedGrid[row][col] = true;
        } else {
          occupiedGrid[row][col] = false;
        }
        placedBlocks[row][col] = null;
        visualGrid[row][col] = null;
      }
    }
    
    activeBlocks.clear();
    
    scoring.reset();
    _updateUI();
    
    spawnThreeBlocks();
    
    print('✅ Game restarted successfully with grid lines preserved');
  }
  
  void _saveCurrentState() {
    // Create block IDs grid for undo system
    final List<List<int>> blockIds = List.generate(
      extendedGridSize,
      (row) => List.generate(extendedGridSize, (col) {
        final block = placedBlocks[row][col];
        return block?.hashCode ?? -1; // Use hashCode as unique ID
      }),
    );
    
    // Save state using improved undo manager
    undoManager.saveState(
      occupiedGrid: occupiedGrid,
      blockIds: blockIds,
      activeBlocks: activeBlocks,
      score: scoring.currentScore,
      level: scoring.level,
      linesCleared: scoring.linesCleared,
      comboCount: scoring.comboCount,
      streakCount: scoring.streakCount,
    );
  }
  
  bool performUndo() {
    final previousState = undoManager.performUndo();
    if (previousState == null) {
      print('❌ Cannot perform undo');
      return false;
    }
    
    print('↩️ Starting undo process...');
    
    // Reset game over flags
    _gameOver = false;
    _gameOverProcessed = false;
    
    // Remove all current block components
    final componentsToRemove = <Component>[];
    for (final child in children) {
      if (child is BlockComponent) {
        componentsToRemove.add(child);
      }
      // Remove placed block visuals (purple squares)
      if (child is RectangleComponent && 
          child.size.x == cellSize && 
          child.size.y == cellSize &&
          child.paint.color == Colors.deepPurpleAccent) {
        componentsToRemove.add(child);
      }
    }
    
    for (final component in componentsToRemove) {
      remove(component);
    }
    print('🗑️ Removed ${componentsToRemove.length} block components');
    
    // Restore grid state
    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        occupiedGrid[row][col] = previousState.occupiedGrid[row][col];
        placedBlocks[row][col] = null; // Clear all references
      }
    }
    
    // Clear and recreate active blocks
    activeBlocks.clear();
    
    for (final entry in previousState.activeBlockShapes.entries) {
      final blockId = entry.key;
      final shape = entry.value;
      final position = previousState.activeBlockPositions[blockId];
      
      if (position != null) {
        final block = BlockComponent(shape: shape);
        block.updateOriginalPosition(position);
        block.isLocked = false;
        
        activeBlocks.add(block);
        add(block);
      }
    }
    
    // Restore scoring state
    scoring.restoreState(
      previousState.score,
      previousState.level,
      previousState.linesCleared,
      previousState.comboCount,
      previousState.streakCount,
    );
    
    // Recreate placed block visuals
    _recreatePlacedBlockVisuals();
    
    // Update UI
    _updateUI();
    
    print('✅ Undo completed successfully - ${activeBlocks.length} active blocks restored');
    return true;
  }
  
  void _recreatePlacedBlockVisuals() {
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (occupiedGrid[row][col]) {
          final visualBlock = RectangleComponent(
            position: gridPositions[row][col],
            size: Vector2(cellSize, cellSize),
            paint: Paint()..color = Colors.deepPurpleAccent,
          );
          add(visualBlock);
        }
      }
    }
    print('🎨 Recreated placed block visuals');
  }
  
  void onUndoButtonTapped() {
    print('🔄 Undo button tapped - checking availability...');
    
    if (undoManager.canUndo) {
      print('✅ Undo available - performing undo...');
      final success = performUndo();
      if (success) {
        print('✅ Undo successful!');
        // ✅ ADD: Play undo sound effect
        AssetManager.playSfx('sfx_click');
      } else {
        print('❌ Undo failed!');
        AssetManager.playSfx('sfx_error');
      }
    } else if (undoManager.remainingUndos == 0) {
      print('💰 No undos remaining - showing purchase dialog...');
      _showUndoOfferDialog();
    } else {
      print('ℹ️ No moves to undo');
      AssetManager.playSfx('sfx_error');
    }
  }
  
  bool get isGameOver => _gameOver;
  double get gridFillPercentage => GameOverManager.getGridFillPercentage(this);
  Map<String, dynamic> get gameStateInfo => GameOverManager.getGameState(this);
  
  // ✅ Remove manual tap detection since button handles its own taps
  @override
  bool onTapUp(TapUpEvent event) {
    // The UndoButtonComponent now handles its own taps
    return false;
  }
  
  void _showUndoOfferDialog() {
    print('💰 Showing undo purchase/ad dialog...');
    // For now, give 3 more free undos (later: implement ads/purchase)
    undoManager.addUndos(3);
    _updateUI();
    AssetManager.playSfx('sfx_reward');
    print('🎁 Granted 3 bonus undos!');
  }
}
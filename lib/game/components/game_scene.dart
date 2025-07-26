import 'package:box_shot/game/game_state.dart';
import 'package:box_shot/game/managers/undo_manager.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../factory/shape_factory.dart';
import '../managers/scoring_manager.dart';
import '../managers/game_over_manager.dart'; // ✅ NEW: Import game over detection
import 'block_component.dart';
import 'block_slot_component.dart' as slot;

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
  final UndoManager undoManager = UndoManager(); // ✅ NEW: Undo system
  late TextComponent scoreDisplay;
  late TextComponent levelDisplay;
  late TextComponent comboDisplay;
  late TextComponent undoButton; // ✅ NEW: Undo button
  
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

  // ✅ Create UI elements - simple approach
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
    
    // ✅ Simple undo button - just text for now
    undoButton = TextComponent(
      text: '🔄 UNDO (3)',
      position: Vector2(20, 120),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(undoButton);
  }

  // ✅ Update UI displays - simple approach
  void _updateUI() {
    final data = scoring.getScoreData();
    final undoStatus = undoManager.getUndoStatus();
    
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
    
    // ✅ Update undo button
    if (undoStatus['canUndo'] as bool) {
      undoButton.text = '🔄 UNDO (${undoStatus['remainingUndos']})';
      undoButton.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      undoButton.text = '🔄 NO UNDO';
      undoButton.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }
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
    
    // ✅ NEW: Check for game over after spawning new blocks
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
    // ✅ Prevent moves if game is over
    if (_gameOver) return;
    
    // ✅ NEW: Save state before making the move
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

    // ✅ Award points for block placement
    scoring.awardBlockPlacement(cellsPlaced);
    _updateUI();

    checkForCompletedLines();
    
    // ✅ NEW: Check for game over after each move
    _checkGameOver();
  }

  void checkForCompletedLines() {
    List<int> completedRows = [];
    List<int> completedCols = [];

    // Check rows
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

    // Check columns
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

    // Handle line clearing
    if (completedRows.isNotEmpty || completedCols.isNotEmpty) {
      clearLines(completedRows, completedCols);
    } else {
      // ✅ Reset combo if no lines cleared
      scoring.resetCombo();
      _updateUI();
    }
  }

  void clearLines(List<int> rows, List<int> cols) {
    Set<Vector2> cellsToRemove = {};
    Map<BlockComponent, Set<Vector2>> affectedBlocks = {};

    // Collect all cells that need to be cleared
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

    // Find all blocks that are affected by line clearing
    for (final cell in cellsToRemove) {
      final row = cell.y.toInt();
      final col = cell.x.toInt();
      
      if (placedBlocks[row][col] != null) {
        final block = placedBlocks[row][col]!;
        
        if (!affectedBlocks.containsKey(block)) {
          affectedBlocks[block] = {};
        }
        affectedBlocks[block]!.add(cell);
        
        // Clear the cell
        occupiedGrid[row][col] = false;
        placedBlocks[row][col] = null;
      }
    }

    // Process each affected block
    for (final entry in affectedBlocks.entries) {
      final block = entry.key;
      final clearedCells = entry.value;
      
      // Find remaining cells of this block
      final remainingCells = _findRemainingCells(block, clearedCells);
      
      if (remainingCells.isNotEmpty) {
        _createBlockFromCells(remainingCells);
      }
      
      // Remove the original block
      remove(block);
    }

    // ✅ Award points for line clearing
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

  // ✅ NEW: Check if board is completely clear
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
    
    // Find all cells this block currently occupies
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (placedBlocks[row][col] == block) {
          final cellPos = Vector2(col.toDouble(), row.toDouble());
          
          // If this cell wasn't cleared, it's remaining
          if (!clearedCells.contains(cellPos)) {
            remainingCells.add(cellPos);
          }
        }
      }
    }
    
    return remainingCells;
  }

  void _createBlockFromCells(Set<Vector2> cells) {
    // Create individual 1x1 blocks for each remaining cell
    for (final cell in cells) {
      final row = cell.y.toInt();
      final col = cell.x.toInt();
      
      // Create a 1x1 block
      final newBlock = BlockComponent(shape: [[1]]);
      newBlock.position = gridPositions[row][col];
      newBlock.isLocked = true;
      
      add(newBlock);
      
      // Mark cell as occupied by new block
      occupiedGrid[row][col] = true;
      placedBlocks[row][col] = newBlock;
    }
  }

  // ✅ REVERTED: Simple game over detection (working version)
  void _checkGameOver() {
    if (_gameOver || _gameOverProcessed) return;
    
    final isGameOver = GameOverManager.isGameOver(this);
    
    if (isGameOver) {
      _gameOver = true;
      _handleGameOver();
    } else {
      // ✅ Optional: Check if game is in danger
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
    
    // Print final game analysis
    GameOverManager.printGameAnalysis(this);
    
    final finalScore = scoring.currentScore;
    final level = scoring.level;
    
    print('🏆 Final Score: $finalScore');
    print('📊 Final Level: $level');
    
    // ✅ Disable all active blocks
    for (final block in activeBlocks) {
      block.isLocked = true;
    }
    
    // ✅ Show game over overlay (will implement UI later)
    _showGameOverScreen();
  }
  
  void _showDangerWarning() {
    // ✅ Optional: Visual warning when few moves remain
    // For now, just print - will add UI effects later
    print('⚠️ Few moves remaining - plan carefully!');
  }
  
  void _showGameOverScreen() {
    print('💀 Showing game over screen...');
    
    // Get final game data
    final finalScore = scoring.currentScore;
    final level = scoring.level;
    final linesCleared = scoring.linesCleared;
    final fillPercentage = GameOverManager.getGridFillPercentage(this);
    final canUndo = undoManager.canUndo; // ✅ NEW: Check if undo is available
    
    // Remove any existing overlays and show game over
    gameRef.overlays.removeAll(['MainMenu', 'AnimatedSplash']);
    gameRef.overlays.add('GameOver');
    gameRef.currentState = GameState.gameOver;
    
    print('✅ Game over overlay should now be visible (undo available: $canUndo)');
  }
  
  // ✅ NEW: Restart game functionality with proper visual cleanup and undo reset
  void restartGame() {
    print('🔄 Restarting game...');
    
    // Reset game state
    _gameOver = false;
    _gameOverProcessed = false;
    
    // ✅ Reset undo system for new game
    undoManager.resetForNewGame();
    
    // ✅ FIX: Remove ONLY placed block components, keep grid lines and UI
    final componentsToRemove = <Component>[];
    
    // Find and remove only the filled block components (placed blocks)
    for (final child in children) {
      if (child is BlockComponent) {
        componentsToRemove.add(child);
      }
      // Remove only FILLED RectangleComponent blocks (solid purple ones)
      if (child is RectangleComponent && 
          child.size.x == cellSize && 
          child.size.y == cellSize &&
          child.paint.color == Colors.deepPurpleAccent) { // ✅ Only remove purple filled blocks
        componentsToRemove.add(child);
      }
    }
    
    // Remove all found components
    for (final component in componentsToRemove) {
      remove(component);
    }
    
    print('🗑️ Removed ${componentsToRemove.length} block components (kept grid lines)');
    
    // Clear all grids
    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        if (row == 0 || col == 0 || row == extendedGridSize - 1 || col == extendedGridSize - 1) {
          occupiedGrid[row][col] = true; // Keep boundaries
        } else {
          occupiedGrid[row][col] = false;
        }
        placedBlocks[row][col] = null;
        visualGrid[row][col] = null;
      }
    }
    
    // Clear active blocks list
    activeBlocks.clear();
    
    // Reset scoring
    scoring.reset();
    _updateUI();
    
    // Spawn new blocks
    spawnThreeBlocks();
    
    print('✅ Game restarted successfully with grid lines preserved');
  }
  
  // ✅ NEW: Undo system methods
  void _saveCurrentState() {
    final currentState = UndoGameState(
      occupiedGrid: occupiedGrid,
      placedBlocks: placedBlocks,
      activeBlocks: activeBlocks,
      score: scoring.currentScore,
      level: scoring.level,
      linesCleared: scoring.linesCleared,
      comboCount: scoring.comboCount,
      streakCount: scoring.streakCount,
    );
    
    undoManager.saveState(currentState);
  }
  
  bool performUndo() {
    final previousState = undoManager.performUndo();
    if (previousState == null) {
      print('❌ Cannot perform undo');
      return false;
    }
    
    // ✅ FIX: Reset game over state when undoing
    _gameOver = false;
    _gameOverProcessed = false;
    
    // ✅ Clear current visual blocks
    final componentsToRemove = <Component>[];
    for (final child in children) {
      if (child is BlockComponent) {
        componentsToRemove.add(child);
      }
      // Remove filled blocks but keep grid lines and UI
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
    
    // ✅ Restore previous state
    occupiedGrid.clear();
    occupiedGrid.addAll(previousState.occupiedGrid);
    
    placedBlocks.clear();
    placedBlocks.addAll(previousState.placedBlocks);
    
    activeBlocks.clear();
    activeBlocks.addAll(previousState.activeBlocks);
    
    // ✅ Restore scoring
    scoring.restoreState(
      previousState.score,
      previousState.level,
      previousState.linesCleared,
      previousState.comboCount,
      previousState.streakCount,
    );
    
    // ✅ Re-add visual blocks from restored state
    _recreateVisualState();
    
    _updateUI();
    print('✅ Undo completed successfully - game state reset');
    return true;
  }
  
  void _recreateVisualState() {
    // Re-add active blocks to scene
    for (final block in activeBlocks) {
      // ✅ FIX: Ensure blocks are unlocked and draggable
      block.isLocked = false;
      add(block);
    }
    
    // Re-create placed blocks visuals
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (occupiedGrid[row][col] && placedBlocks[row][col] != null) {
          // Create visual representation
          final visualBlock = RectangleComponent(
            position: gridPositions[row][col],
            size: Vector2(cellSize, cellSize),
            paint: Paint()..color = Colors.deepPurpleAccent,
          );
          add(visualBlock);
        }
      }
    }
    
    print('🔄 Visual state recreated: ${activeBlocks.length} active blocks restored');
  }
  
  // ✅ NEW: Handle undo button tap (to be called from input handler)
  void onUndoButtonTapped() {
    if (undoManager.canUndo) {
      performUndo();
    } else if (undoManager.remainingUndos == 0) {
      // Show purchase/ad dialog
      _showUndoOfferDialog();
    } else {
      print('ℹ️ No moves to undo');
    }
  }
  
  // ✅ NEW: Public getters for game state
  bool get isGameOver => _gameOver;
  double get gridFillPercentage => GameOverManager.getGridFillPercentage(this);
  Map<String, dynamic> get gameStateInfo => GameOverManager.getGameState(this);
  
  // ✅ NEW: Simple tap detection for undo button
  @override
  bool onTapUp(TapUpEvent event) {
    final tapPosition = event.localPosition;
    
    // Define undo button area (around the text position)
    final undoArea = Rect.fromLTWH(
      undoButton.position.x - 10,
      undoButton.position.y - 10,
      150, // Wide enough to tap easily
      40,  // Tall enough to tap easily
    );
    
    if (undoArea.contains(tapPosition.toOffset())) {
      print('🖱️ Undo area tapped!');
      onUndoButtonTapped();
      return true;
    }
    
    return false;
  }
  
  void _showUndoOfferDialog() {
    print('💰 Show undo purchase/ad dialog');
    // TODO: Implement purchase/ad dialog
    // For now, give free undo for testing
    undoManager.addUndos(3);
    _updateUI();
  }
}
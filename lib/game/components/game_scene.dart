import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../box_hooks_game.dart';
import '../factory/shape_factory.dart';
import '../managers/scoring_manager.dart';
import '../managers/game_over_manager.dart';
import '../managers/undo_manager.dart';
import '../managers/power_up_manager.dart';
import '../managers/coin_manager.dart';
import '../managers/achievement_manager.dart';
import '../game_state.dart';
import '../../services/asset_manager.dart';
import 'block_component.dart';
import 'block_slot_component.dart' as slot;
import 'undo_button_component.dart';
import 'power_up_panel_component.dart'; // ✅ NEW: Added import


class GameScene extends PositionComponent with HasGameRef<BoxHooksGame>, TapCallbacks {
  static const int gridSize = 8;
  static const double cellSize = 36;
  static const double spacing = 3;
  static const int extendedGridSize = gridSize + 2;
  static const double _precisionTolerance = 0.1;

  // ✅ FIXED: Make all grid properties public for power-up access
  late List<List<Vector2>> gridPositions;
  late List<List<bool>> occupiedGrid;
  late List<List<Component?>> visualGrid;
  late List<List<BlockComponent?>> placedBlocks;
  
  late double _gridStartX;
  late double _gridStartY;
  late double _cellStep;

  // ✅ Core systems
  final ScoringManager scoring = ScoringManager();
  final UndoManager undoManager = UndoManager();
  
  // ✅ Enhancement managers  
  final PowerUpManager powerUpManager = PowerUpManager();
  final CoinManager coinManager = CoinManager();
  final AchievementManager achievementManager = AchievementManager();
  
  // ✅ Game tracking
  bool _usedUndoThisGame = false;
  int _blocksPlacedThisGame = 0;
  int _coinsEarnedThisGame = 0;
  DateTime? _gameStartTime;

  // UI components
  late TextComponent scoreDisplay;
  late TextComponent levelDisplay;
  late TextComponent comboDisplay;
  late TextComponent coinDisplay;
  late UndoButtonComponent undoButtonComponent;
  
  // ✅ NEW: Power-up panel instead of old button
  late PowerUpPanelComponent powerUpPanel;
  
  // ✅ KEPT: Original power-up button components (commented out but preserved)
  // late RectangleComponent powerUpButton;
  // late TextComponent powerUpButtonText;
  
  bool _gameOver = false;
  bool _gameOverProcessed = false;

  final List<BlockComponent> activeBlocks = [];
  final List<slot.BlockSlotComponent> slots = [];
  
  List<BlockComponent> get activeBlocksList => activeBlocks;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // ✅ FIXED: Initialize enhancement systems first
    await coinManager.initialize();
    await achievementManager.initialize();
    
    _gameStartTime = DateTime.now();
    _coinsEarnedThisGame = 0;
    
    _cellStep = cellSize + spacing;
    final screenSize = gameRef.size;
    final totalSize = (cellSize * gridSize) + (spacing * (gridSize - 1));
    _gridStartX = ((screenSize.x - totalSize) / 2).roundToDouble() - _cellStep;
    _gridStartY = ((screenSize.y - totalSize) / 2).roundToDouble() - _cellStep;

    _initializeGrids();
    _createGridVisuals();
    _createUI();
    _createSlots();
    spawnThreeBlocks();
  }

  void _initializeGrids() {
    gridPositions = List.generate(extendedGridSize, (_) => List.filled(extendedGridSize, Vector2.zero()));
    occupiedGrid = List.generate(extendedGridSize, (r) => List.generate(extendedGridSize, (c) => r == 0 || c == 0 || r == extendedGridSize - 1 || c == extendedGridSize - 1));
    placedBlocks = List.generate(extendedGridSize, (_) => List.filled(extendedGridSize, null));
    visualGrid = List.generate(extendedGridSize, (_) => List.filled(extendedGridSize, null));

    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        gridPositions[row][col] = Vector2(
          (_gridStartX + col * _cellStep).roundToDouble(),
          (_gridStartY + row * _cellStep).roundToDouble(),
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
          paint: Paint()..color = Colors.grey.shade600..style = PaintingStyle.stroke..strokeWidth = 1.5,
        );
        add(cell);
      }
    }
  }

  void _createUI() {
    final screenSize = gameRef.size;
    
    scoreDisplay = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 50),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
    );
    add(scoreDisplay);
    
    levelDisplay = TextComponent(
      text: 'Level: 1',
      position: Vector2(screenSize.x - 200, 50), // ✅ MOVED: Adjusted for power-up panel space
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
    add(levelDisplay);
    
    comboDisplay = TextComponent(
      text: '',
      position: Vector2(screenSize.x / 2 - 50, 100),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
    );
    add(comboDisplay);

    // ✅ Coin display
    coinDisplay = TextComponent(
      text: '💰 ${coinManager.currentCoins}',
      position: Vector2(20, 200),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
    );
    add(coinDisplay);

    // ✅ NEW: Power-up panel instead of old button
    powerUpPanel = PowerUpPanelComponent();
    add(powerUpPanel);

    // ✅ PRESERVED: Original power-up button code (commented out but kept for reference)
    /*
    powerUpButton = RectangleComponent(
      position: Vector2(20, 150),
      size: Vector2(120, 35),
      paint: Paint()..color = Colors.purple.withAlpha(204)..style = PaintingStyle.fill,
    );
    add(powerUpButton);
    
    powerUpButtonText = TextComponent(
      text: '🔥 POWER-UPS',
      position: Vector2(80, 167),
      anchor: Anchor.center,
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
    );
    add(powerUpButtonText);
    */
    
    undoButtonComponent = UndoButtonComponent(
      position: Vector2(screenSize.x - 230, 85), // ✅ MOVED: Adjusted for power-up panel space
      onPressed: onUndoButtonTapped,
      getText: () {
        final remaining = undoManager.remainingUndos;
        return remaining > 0 ? '↩️ UNDO ($remaining)' : '↩️ NO UNDO';
      },
      isEnabled: () => undoManager.canUndo,
    );
    add(undoButtonComponent);
  }

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

    // ✅ Update coin display
    coinDisplay.text = '💰 ${coinManager.currentCoins}';
    
    // ✅ NEW: Update power-up panel
    powerUpPanel.updateDisplay();
    
    undoButtonComponent.updateAppearance();
  }

  // ✅ FIXED: Make these methods public for power-up access
  Vector2 worldToGrid(Vector2 worldPos) {
    final relativeX = worldPos.x - _gridStartX;
    final relativeY = worldPos.y - _gridStartY;
    final col = (relativeX / _cellStep + 0.5).floor();
    final row = (relativeY / _cellStep + 0.5).floor();
    return Vector2(col.toDouble(), row.toDouble());
  }

  bool isValidGridPos(int row, int col) {
    return row > 0 && col > 0 && row < extendedGridSize - 1 && col < extendedGridSize - 1;
  }

  Vector2 getSnapPosition(Vector2 worldPos) {
    final gridCoord = worldToGrid(worldPos);
    final row = gridCoord.y.toInt().clamp(1, extendedGridSize - 2);
    final col = gridCoord.x.toInt().clamp(1, extendedGridSize - 2);
    return gridPositions[row][col];
  }

  void _createSlots() {
    const slotSpacing = 40.0;
    final screenWidth = gameRef.size.x;
    final centerY = gameRef.size.y - 200;
    final totalWidth = 3 * slot.BlockSlotComponent.slotWidth + 2 * slotSpacing;
    final startX = (screenWidth - totalWidth) / 2;

    for (int i = 0; i < 3; i++) {
      final x = startX + i * (slot.BlockSlotComponent.slotWidth + slotSpacing);
      final slotComponent = slot.BlockSlotComponent(index: i)..position = Vector2(x, centerY);
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
          Vector2((slot.BlockSlotComponent.slotWidth - block.size.x) / 2, (slot.BlockSlotComponent.slotHeight - block.size.y) / 2);

      activeBlocks.add(block);
      add(block);
    }
    
    Future.microtask(() => _checkGameOver());
  }

  bool canPlaceBlock(BlockComponent block, Vector2 snapPosition) {
    final gridCoord = worldToGrid(snapPosition);
    final baseRow = gridCoord.y.toInt();
    final baseCol = gridCoord.x.toInt();

    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 0) continue;

        final gridRow = baseRow + shapeRow;
        final gridCol = baseCol + shapeCol;

        if (!isValidGridPos(gridRow, gridCol)) return false;
        if (occupiedGrid[gridRow][gridCol]) return false;
      }
    }
    return true;
  }

  // ✅ ENHANCED: markBlockOccupied with power-up and achievement integration
  void markBlockOccupied(BlockComponent block, Vector2 snapPosition) {
    if (_gameOver) return;
    
    // ✅ FIXED: Check for power-up usage first
    if (powerUpManager.isWaitingForTarget) {
      final success = powerUpManager.usePowerUpAt(this, snapPosition);
      if (success) {
        _updateUI(); // Update UI after power-up use
        return; // Power-up was used, don't place block
      }
    }
    
    _saveCurrentState();
    
    final gridCoord = worldToGrid(snapPosition);
    final baseRow = gridCoord.y.toInt();
    final baseCol = gridCoord.x.toInt();
    
    int cellsPlaced = 0;

    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 0) continue;

        final gridRow = baseRow + shapeRow;
        final gridCol = baseCol + shapeCol;

        if (isValidGridPos(gridRow, gridCol)) {
          occupiedGrid[gridRow][gridCol] = true;
          placedBlocks[gridRow][gridCol] = block;
          cellsPlaced++;
        }
      }
    }

    // ✅ ENHANCED: Award coins and track achievements
    _blocksPlacedThisGame++;
    final blockCoins = cellsPlaced;
    coinManager.awardCoins('block_placed', customAmount: blockCoins);
    _coinsEarnedThisGame += blockCoins;
    achievementManager.onBlockPlaced();

    scoring.awardBlockPlacement(cellsPlaced);
    _updateUI();

    checkForCompletedLines();
    Future.microtask(() => _checkGameOver());
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
      if (isRowComplete) completedRows.add(row);
    }

    for (int col = 1; col < extendedGridSize - 1; col++) {
      bool isColComplete = true;
      for (int row = 1; row < extendedGridSize - 1; row++) {
        if (!occupiedGrid[row][col]) {
          isColComplete = false;
          break;
        }
      }
      if (isColComplete) completedCols.add(col);
    }

    if (completedRows.isNotEmpty || completedCols.isNotEmpty) {
      clearLines(completedRows, completedCols);
    } else {
      scoring.resetCombo();
      _updateUI();
    }
  }

  // ✅ ENHANCED: clearLines with coin and achievement integration
  void clearLines(List<int> rows, List<int> cols) {
    if (rows.isEmpty && cols.isEmpty) {
      scoring.resetCombo();
      _updateUI();
      return;
    }

    // Award coins for line clearing
    final totalLines = rows.length + cols.length;
    final lineCoins = totalLines * 10;
    coinManager.awardCoins('line_cleared', customAmount: lineCoins);
    _coinsEarnedThisGame += lineCoins;
    
    // Award combo bonuses
    if (scoring.comboCount > 1) {
      final comboCoins = scoring.comboCount * 10;
      coinManager.awardCoins('combo_bonus', customAmount: comboCoins);
      _coinsEarnedThisGame += comboCoins;
    }
    
    // Track achievements
    achievementManager.onLineCleared(totalLines);
    achievementManager.onComboAchieved(scoring.comboCount);
    achievementManager.onScoreAchieved(scoring.currentScore);
    
    // Check for perfect clear
    final isPerfectClear = _checkPerfectClear();
    if (isPerfectClear) {
      final perfectCoins = 100;
      coinManager.awardCoins('perfect_clear', customAmount: perfectCoins);
      _coinsEarnedThisGame += perfectCoins;
      achievementManager.onPerfectClear();
    }

    // Perform the actual line clearing
    _performLineClear(rows, cols);
  }

  void _performLineClear(List<int> rows, List<int> cols) {
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
        if (occupiedGrid[row][col]) return false;
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
    
    print('🔍 Checking game over state...');
    
    if (activeBlocks.isEmpty) {
      print('✅ No active blocks - game continues');
      return;
    }
    
    bool canPlaceAnyBlock = false;
    
    for (int blockIndex = 0; blockIndex < activeBlocks.length; blockIndex++) {
      final block = activeBlocks[blockIndex];
      
      for (int testRow = 1; testRow < extendedGridSize - 1; testRow++) {
        for (int testCol = 1; testCol < extendedGridSize - 1; testCol++) {
          final testPosition = gridPositions[testRow][testCol];
          
          if (canPlaceBlock(block, testPosition)) {
            canPlaceAnyBlock = true;
            break;
          }
        }
        if (canPlaceAnyBlock) break;
      }
      if (canPlaceAnyBlock) break;
    }
    
    if (!canPlaceAnyBlock) {
      print('💀 GAME OVER - No valid moves remaining');
      _gameOver = true;
      _handleGameOver();
    }
  }
  
  // ✅ ENHANCED: _handleGameOver with all tracking
  void _handleGameOver() {
    if (_gameOverProcessed) return;
    _gameOverProcessed = true;
    
    print('🎮 GAME OVER!');
    
    // Calculate game duration
    final gameDuration = _gameStartTime != null 
        ? DateTime.now().difference(_gameStartTime!).inSeconds 
        : 0;
    
    // Award completion coins
    final completionCoins = 25;
    coinManager.awardCoins('game_complete', customAmount: completionCoins);
    _coinsEarnedThisGame += completionCoins;
    
    // Track final achievements
    achievementManager.onGameCompleted(!_usedUndoThisGame);
    achievementManager.onLevelReached(scoring.level);
    achievementManager.onGameDuration(gameDuration);
    achievementManager.onScoreAchieved(scoring.currentScore);
    
    for (final block in activeBlocks) {
      block.isLocked = true;
    }
    
    _showGameOverScreen();
  }
  
  void _showGameOverScreen() {
    print('💀 Showing game over screen...');
    
    final unlockedAchievements = achievementManager.getRecentlyUnlocked();
    
    // Grant achievement rewards
    for (final achievementId in unlockedAchievements) {
      achievementManager.grantRewards(achievementId, coinManager, powerUpManager);
    }
    
    gameRef.overlays.removeAll(['MainMenu', 'AnimatedSplash']);
    gameRef.overlays.add('GameOver');
    gameRef.currentState = GameState.gameOver;
    
    print('✅ Game over overlay visible');
    print('💰 Coins earned this game: $_coinsEarnedThisGame');
  }
  
  void restartGame() {
    print('🔄 Restarting game...');
    
    _gameOver = false;
    _gameOverProcessed = false;
    _usedUndoThisGame = false;
    _blocksPlacedThisGame = 0;
    _coinsEarnedThisGame = 0;
    _gameStartTime = DateTime.now();
    
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
  }
  
  void _saveCurrentState() {
    final List<List<int>> blockIds = List.generate(
      extendedGridSize,
      (row) => List.generate(extendedGridSize, (col) {
        final block = placedBlocks[row][col];
        return block?.hashCode ?? -1;
      }),
    );
    
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
    if (previousState == null) return false;
    
    _usedUndoThisGame = true;
    
    _gameOver = false;
    _gameOverProcessed = false;
    
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
    
    for (int row = 0; row < extendedGridSize; row++) {
      for (int col = 0; col < extendedGridSize; col++) {
        occupiedGrid[row][col] = previousState.occupiedGrid[row][col];
        placedBlocks[row][col] = null;
      }
    }
    
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
    
    scoring.restoreState(
      previousState.score,
      previousState.level,
      previousState.linesCleared,
      previousState.comboCount,
      previousState.streakCount,
    );
    
    _recreatePlacedBlockVisuals();
    _updateUI();
    
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
  }
  
  void onUndoButtonTapped() {
    if (undoManager.canUndo) {
      final success = performUndo();
      if (success) {
        AssetManager.playSfx('sfx_click');
      } else {
        AssetManager.playSfx('sfx_error');
      }
    } else if (undoManager.remainingUndos == 0) {
      _showUndoOfferDialog();
    } else {
      AssetManager.playSfx('sfx_error');
    }
  }
  
  bool get isGameOver => _gameOver;
  double get gridFillPercentage => GameOverManager.getGridFillPercentage(this);
  
  // ✅ MODIFIED: Enhanced tap handling for power-ups (removed old power-up button check)
  @override
  bool onTapUp(TapUpEvent event) {
    // ✅ REMOVED: Old power-up button tap check (now handled by power-up panel)
    /*
    // Check power-up button tap
    final powerUpButtonRect = Rect.fromLTWH(20, 150, 120, 35);
    if (powerUpButtonRect.contains(event.localPosition.toOffset())) {
      _showPowerUpMenu();
      return true;
    }
    */

    // Check if we're waiting for power-up target
    if (powerUpManager.isWaitingForTarget) {
      final success = powerUpManager.usePowerUpAt(this, event.localPosition);
      if (success) {
        print('✅ Power-up used successfully');
        _updateUI(); // ✅ CHANGED: Update UI instead of removing overlay
        return true;
      } else {
        print('❌ Invalid power-up target');
        return true;
      }
    }
    
    return false;
  }
  
  // ✅ PRESERVED: Old power-up menu methods (kept for reference but not used)
  /*
  void _showPowerUpMenu() {
    print('🔥 Opening power-up menu');
    gameRef.overlays.add('PowerUpMenu');
  }
  */
  void _showUndoOfferDialog() {
   undoManager.addUndos(3);
   _updateUI();
   AssetManager.playSfx('sfx_reward');
   print('🎁 Granted 3 bonus undos!');
 }

 // ✅ Power-up system integration methods
 void activatePowerUp(PowerUpType type) {
   powerUpManager.activatePowerUp(type);
 }

 void cancelPowerUp() {
   powerUpManager.cancelActivePowerUp();
 }

 bool hasPowerUp(PowerUpType type) {
   return powerUpManager.hasPowerUp(type);
 }

 // ✅ Coin management methods
 int getCurrentCoins() {
   return coinManager.currentCoins;
 }

 bool purchasePowerUp(PowerUpType type) {
   return coinManager.purchasePowerUp(type, powerUpManager);
 }

 int getCoinsEarnedThisGame() {
   return _coinsEarnedThisGame;
 }

 // ✅ Achievement system methods
 List<Achievement> getUnlockedAchievements() {
   return achievementManager.getUnlockedAchievements();
 }

 double getAchievementProgress() {
   return achievementManager.getCompletionPercentage();
 }

 List<String> getRecentlyUnlockedAchievements() {
   return achievementManager.getRecentlyUnlocked();
 }

 // ✅ Power-up inventory access
 Map<PowerUpType, int> getPowerUpInventory() {
   return powerUpManager.inventory;
 }

 // ✅ PRESERVED: Old overlay methods (kept for compatibility)
 void hidePowerUpMenu() {
   gameRef.overlays.remove('PowerUpMenu');
 }
 
}

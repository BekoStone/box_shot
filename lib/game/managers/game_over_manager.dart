import 'dart:ui';

import 'package:flame/components.dart';

import '../components/block_component.dart';
import '../components/game_scene.dart';

class GameOverManager {
  
  // ✅ FIXED: More robust game over detection with comprehensive checking
  static bool isGameOver(GameScene scene) {
    final activeBlocks = scene.activeBlocksList;
    
    // If no active blocks, game is not over (new blocks will spawn)
    if (activeBlocks.isEmpty) {
      return false;
    }
    
    print('🔍 Checking game over for ${activeBlocks.length} active blocks...');
    
    // Check if ANY active block can be placed ANYWHERE on the grid
    for (int blockIndex = 0; blockIndex < activeBlocks.length; blockIndex++) {
      final block = activeBlocks[blockIndex];
      if (_canBlockBePlacedAnywhere(scene, block, blockIndex)) {
        print('✅ Block $blockIndex can still be placed - game continues');
        return false; // Found at least one valid placement
      }
    }
    
    print('💀 GAME OVER - No valid moves remaining');
    return true; // No valid placements found for any block
  }
  
  // ✅ FIXED: More comprehensive placement checking
  static bool _canBlockBePlacedAnywhere(GameScene scene, BlockComponent block, int blockIndex) {
    const int extendedGridSize = GameScene.extendedGridSize;
    int validPositions = 0;
    
    print('🔍 Checking block $blockIndex (${block.shape.length}x${block.shape[0].length})...');
    
    // Try every possible position on the playable grid (excluding boundaries)
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        
        // ✅ FIXED: Check both grid placement AND collision with other blocks
        if (scene.canPlaceBlock(block, testPosition) && 
            !_wouldCollideWithActiveBlocks(scene, block, testPosition)) {
          validPositions++;
          print('✅ Block $blockIndex can be placed at ($row, $col)');
          return true; // Found at least one valid position
        }
      }
    }
    
    print('❌ Block $blockIndex cannot be placed anywhere (checked ${(extendedGridSize-2)*(extendedGridSize-2)} positions)');
    return false;
  }
  
  // ✅ FIXED: Check collision with other active blocks during game over detection
  static bool _wouldCollideWithActiveBlocks(GameScene scene, BlockComponent testBlock, Vector2 testPosition) {
    final testRect = Rect.fromLTWH(
      testPosition.x,
      testPosition.y,
      testBlock.size.x,
      testBlock.size.y,
    );
    
    for (final otherBlock in scene.activeBlocksList) {
      if (otherBlock != testBlock && !otherBlock.isLocked) {
        final otherRect = otherBlock.toRect();
        if (_rectsOverlap(testRect, otherRect)) {
          return true;
        }
      }
    }
    return false;
  }
  
  // ✅ FIXED: Precise rectangle overlap detection
  static bool _rectsOverlap(Rect rect1, Rect rect2) {
    return rect1.left < rect2.right &&
           rect2.left < rect1.right &&
           rect1.top < rect2.bottom &&
           rect2.top < rect1.bottom;
  }
  
  // ✅ Enhanced: Get available placement count for a block with collision checking
  static int getAvailablePlacements(GameScene scene, BlockComponent block) {
    const int extendedGridSize = GameScene.extendedGridSize;
    int count = 0;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        
        if (scene.canPlaceBlock(block, testPosition) && 
            !_wouldCollideWithActiveBlocks(scene, block, testPosition)) {
          count++;
        }
      }
    }
    
    return count;
  }
  
  // ✅ Enhanced: Get comprehensive game state analysis
  static Map<String, dynamic> getGameState(GameScene scene) {
    final activeBlocks = scene.activeBlocksList;
    int totalPlacements = 0;
    Map<int, int> blockPlacements = {};
    Map<int, String> blockInfo = {};
    
    for (int i = 0; i < activeBlocks.length; i++) {
      final block = activeBlocks[i];
      final placements = getAvailablePlacements(scene, block);
      blockPlacements[i] = placements;
      blockInfo[i] = '${block.shape.length}x${block.shape[0].length} (${block.cellCount} cells)';
      totalPlacements += placements;
    }
    
    final gridFill = getGridFillPercentage(scene);
    final isGameOver = totalPlacements == 0;
    
    return {
      'isGameOver': isGameOver,
      'totalMoves': totalPlacements,
      'blockMoves': blockPlacements,
      'blockInfo': blockInfo,
      'activeBlockCount': activeBlocks.length,
      'gridFillPercentage': gridFill,
      'difficultyLevel': _calculateDifficultyLevel(gridFill, totalPlacements),
    };
  }
  
  // ✅ NEW: Calculate difficulty level based on game state
  static String _calculateDifficultyLevel(double gridFill, int totalMoves) {
    if (gridFill > 80) return 'EXTREME';
    if (gridFill > 60) return 'HARD';
    if (gridFill > 40) return 'MEDIUM';
    if (totalMoves < 10) return 'CHALLENGING';
    return 'EASY';
  }
  
  // ✅ Enhanced: More sophisticated danger detection
  static bool isGameInDanger(GameScene scene, {int dangerThreshold = 5}) {
    final gameState = getGameState(scene);
    final totalMoves = gameState['totalMoves'] as int;
    final gridFill = gameState['gridFillPercentage'] as double;
    
    // Game is in danger if:
    // 1. Very few moves left, OR
    // 2. Grid is very full (>70%), OR 
    // 3. All blocks have very limited placement options
    return (totalMoves <= dangerThreshold && totalMoves > 0) ||
           gridFill > 70.0 ||
           _hasLimitedOptions(scene);
  }
  
  // ✅ NEW: Check if all blocks have very limited placement options
  static bool _hasLimitedOptions(GameScene scene) {
    final activeBlocks = scene.activeBlocksList;
    if (activeBlocks.isEmpty) return false;
    
    int blocksWithFewOptions = 0;
    for (final block in activeBlocks) {
      final placements = getAvailablePlacements(scene, block);
      if (placements <= 3) { // Very few options
        blocksWithFewOptions++;
      }
    }
    
    // If most blocks have few options, game is in danger
    return blocksWithFewOptions >= (activeBlocks.length * 0.6);
  }
  
  // ✅ Enhanced: More precise grid fill calculation
  static double getGridFillPercentage(GameScene scene) {
    const int extendedGridSize = GameScene.extendedGridSize;
    const int totalPlayableCells = (extendedGridSize - 2) * (extendedGridSize - 2); // 8x8 = 64
    
    int occupiedCells = 0;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (scene.occupiedGrid[row][col]) {
          occupiedCells++;
        }
      }
    }
    
    return (occupiedCells / totalPlayableCells) * 100.0;
  }
  
  // ✅ Enhanced: Comprehensive game analysis for debugging
  static void printGameAnalysis(GameScene scene) {
    final gameState = getGameState(scene);
    final fillPercentage = getGridFillPercentage(scene);
    final isInDanger = isGameInDanger(scene);
    
    print('📊 COMPREHENSIVE GAME ANALYSIS:');
    print('   Grid Fill: ${fillPercentage.toStringAsFixed(1)}%');
    print('   Total Moves: ${gameState['totalMoves']}');
    print('   Active Blocks: ${gameState['activeBlockCount']}');
    print('   Difficulty: ${gameState['difficultyLevel']}');
    print('   In Danger: $isInDanger');
    print('   Game Over: ${gameState['isGameOver']}');
    
    final blockMoves = gameState['blockMoves'] as Map<int, int>;
    final blockInfo = gameState['blockInfo'] as Map<int, String>;
    
    print('   📦 BLOCK DETAILS:');
    for (final entry in blockMoves.entries) {
      final blockIndex = entry.key;
      final moves = entry.value;
      final info = blockInfo[blockIndex] ?? 'Unknown';
      print('     Block $blockIndex: $moves moves | $info');
    }
    
    // ✅ NEW: Grid pattern analysis
    _printGridPattern(scene);
  }
  
  // ✅ NEW: Print grid pattern for debugging
  static void _printGridPattern(GameScene scene) {
    print('   🎯 GRID PATTERN:');
    const int extendedGridSize = GameScene.extendedGridSize;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      String line = '     ';
      for (int col = 1; col < extendedGridSize - 1; col++) {
        line += scene.occupiedGrid[row][col] ? '█' : '░';
      }
      print(line);
    }
  }
}
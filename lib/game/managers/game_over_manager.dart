// File: lib/game/managers/game_over_manager.dart

import '../components/block_component.dart';
import '../components/game_scene.dart';

class GameOverManager {
  
  // ✅ Main method: Check if game is over
  static bool isGameOver(GameScene scene) {
    final activeBlocks = scene.activeBlocksList;
    
    // If no active blocks, game is not over (new blocks will spawn)
    if (activeBlocks.isEmpty) {
      return false;
    }
    
    print('🔍 Checking game over for ${activeBlocks.length} active blocks...');
    
    // Check if ANY active block can be placed ANYWHERE on the grid
    for (final block in activeBlocks) {
      if (_canBlockBePlaced(scene, block)) {
        print('✅ Block can still be placed - game continues');
        return false; // Found at least one valid placement
      }
    }
    
    print('💀 GAME OVER - No valid moves remaining');
    return true; // No valid placements found for any block
  }
  
  // ✅ REVERTED: Simple working logic
  static bool _canBlockBePlaced(GameScene scene, BlockComponent block) {
    const int extendedGridSize = GameScene.extendedGridSize;
    
    // Try every possible position on the playable grid (excluding boundaries)
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        
        if (scene.canPlaceBlock(block, testPosition)) {
          print('📍 Block can be placed at ($row, $col)');
          return true;
        }
      }
    }
    
    print('❌ Block cannot be placed anywhere');
    return false;
  }
  
  // ✅ Get available placement count for a block (useful for difficulty analysis)
  static int getAvailablePlacements(GameScene scene, BlockComponent block) {
    const int extendedGridSize = GameScene.extendedGridSize;
    int count = 0;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        
        if (scene.canPlaceBlock(block, testPosition)) {
          count++;
        }
      }
    }
    
    return count;
  }
  
  // ✅ Get total available moves for all active blocks
  static Map<String, dynamic> getGameState(GameScene scene) {
    final activeBlocks = scene.activeBlocksList;
    int totalPlacements = 0;
    Map<int, int> blockPlacements = {};
    
    for (int i = 0; i < activeBlocks.length; i++) {
      final placements = getAvailablePlacements(scene, activeBlocks[i]);
      blockPlacements[i] = placements;
      totalPlacements += placements;
    }
    
    return {
      'isGameOver': totalPlacements == 0,
      'totalMoves': totalPlacements,
      'blockMoves': blockPlacements,
      'activeBlockCount': activeBlocks.length,
    };
  }
  
  // ✅ Advanced: Check if game is in danger (very few moves left)
  static bool isGameInDanger(GameScene scene, {int dangerThreshold = 5}) {
    final gameState = getGameState(scene);
    final totalMoves = gameState['totalMoves'] as int;
    
    return totalMoves <= dangerThreshold && totalMoves > 0;
  }
  
  // ✅ Get percentage of grid filled (useful for difficulty scaling)
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
    
    return (occupiedCells / totalPlayableCells) * 100;
  }
  
  // ✅ Detailed analysis for debugging/strategy
  static void printGameAnalysis(GameScene scene) {
    final gameState = getGameState(scene);
    final fillPercentage = getGridFillPercentage(scene);
    final isInDanger = isGameInDanger(scene);
    
    print('📊 GAME ANALYSIS:');
    print('   Grid Fill: ${fillPercentage.toStringAsFixed(1)}%');
    print('   Total Moves: ${gameState['totalMoves']}');
    print('   Active Blocks: ${gameState['activeBlockCount']}');
    print('   In Danger: $isInDanger');
    print('   Game Over: ${gameState['isGameOver']}');
    
    final blockMoves = gameState['blockMoves'] as Map<int, int>;
    for (final entry in blockMoves.entries) {
      print('   Block ${entry.key}: ${entry.value} possible placements');
    }
  }
}
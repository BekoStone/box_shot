// File: lib/game/managers/power_up_manager.dart

// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../components/game_scene.dart';
import '../components/block_component.dart';
import '../../services/asset_manager.dart';

enum PowerUpType {
  hammer,    // Destroy single block
  bomb,      // Clear 3x3 area  
  shuffle,   // Replace current blocks
  hint,      // Show best placement
  freeze,    // Extra thinking time
}

class PowerUpData {
  final PowerUpType type;
  final String name;
  final String description;
  final int cost;
  final String icon;
  final Color color;

  const PowerUpData({
    required this.type,
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
    required this.color,
  });
}

class PowerUpManager {
  // ✅ Power-up definitions with pricing
  static const Map<PowerUpType, PowerUpData> powerUps = {
    PowerUpType.hammer: PowerUpData(
      type: PowerUpType.hammer,
      name: 'Hammer',
      description: 'Destroy any single block on the grid',
      cost: 50,
      icon: '🔨',
      color: Colors.orange,
    ),
    PowerUpType.bomb: PowerUpData(
      type: PowerUpType.bomb,
      name: 'Bomb',
      description: 'Clear a 3x3 area around target',
      cost: 100,
      icon: '💣',
      color: Colors.red,
    ),
    PowerUpType.shuffle: PowerUpData(
      type: PowerUpType.shuffle,
      name: 'Shuffle',
      description: 'Replace current blocks with new ones',
      cost: 75,
      icon: '🔄',
      color: Colors.blue,
    ),
    PowerUpType.hint: PowerUpData(
      type: PowerUpType.hint,
      name: 'Hint',
      description: 'Highlight the best placement',
      cost: 25,
      icon: '💡',
      color: Colors.yellow,
    ),
    PowerUpType.freeze: PowerUpData(
      type: PowerUpType.freeze,
      name: 'Freeze',
      description: 'Pause and think for 10 seconds',
      cost: 30,
      icon: '❄️',
      color: Colors.cyan,
    ),
  };

  // ✅ Player inventory - FIXED: Start with actual items
  final Map<PowerUpType, int> _inventory = {
    PowerUpType.hammer: 2,    // Start with 2 hammers (you got 1 from achievement!)
    PowerUpType.bomb: 0,
    PowerUpType.shuffle: 1,   // Start with 1 shuffle
    PowerUpType.hint: 3,      // Start with 3 hints
    PowerUpType.freeze: 0,
  };

  // ✅ Active power-up state
  PowerUpType? _activePowerUp;
  bool _waitingForTarget = false;

  // Getters
  PowerUpType? get activePowerUp => _activePowerUp;
  bool get isWaitingForTarget => _waitingForTarget;
  Map<PowerUpType, int> get inventory => Map.unmodifiable(_inventory);

  // ✅ Check if player has power-up
  bool hasPowerUp(PowerUpType type) {
    return (_inventory[type] ?? 0) > 0;
  }

  // ✅ Get power-up count
  int getPowerUpCount(PowerUpType type) {
    return _inventory[type] ?? 0;
  }

  // ✅ Add power-ups (from purchases/rewards)
  void addPowerUp(PowerUpType type, int count) {
    _inventory[type] = (_inventory[type] ?? 0) + count;
    print('🎁 Added $count ${powerUps[type]!.name} power-ups');
  }

  // ✅ Activate power-up
  bool activatePowerUp(PowerUpType type) {
    if (!hasPowerUp(type)) {
      print('❌ No ${powerUps[type]!.name} power-ups available');
      return false;
    }

    _activePowerUp = type;
    
    // Immediate effect power-ups
    if (type == PowerUpType.shuffle || type == PowerUpType.freeze) {
      _usePowerUp(type);
      return true;
    }

    // Target-based power-ups
    _waitingForTarget = true;
    print('🎯 ${powerUps[type]!.name} activated - click target location');
    AssetManager.playSfx('sfx_click');
    return true;
  }

  // ✅ Use power-up at target location
  bool usePowerUpAt(GameScene scene, Vector2 targetPosition) {
    if (_activePowerUp == null || !_waitingForTarget) {
      return false;
    }

    final success = _executePowerUp(_activePowerUp!, scene, targetPosition);
    
    if (success) {
      _usePowerUp(_activePowerUp!);
    }

    _activePowerUp = null;
    _waitingForTarget = false;
    return success;
  }

  // ✅ Execute power-up logic
  bool _executePowerUp(PowerUpType type, GameScene scene, Vector2? targetPosition) {
    switch (type) {
      case PowerUpType.hammer:
        return _executeHammer(scene, targetPosition!);
      
      case PowerUpType.bomb:
        return _executeBomb(scene, targetPosition!);
      
      case PowerUpType.shuffle:
        return _executeShuffle(scene);
      
      case PowerUpType.hint:
        return _executeHint(scene);
      
      case PowerUpType.freeze:
        return _executeFreeze(scene);
    }
  }

  // ✅ HAMMER: Destroy single block
  bool _executeHammer(GameScene scene, Vector2 targetPosition) {
    final gridCoord = scene.worldToGrid(targetPosition);  // ✅ FIXED: Remove underscore
    final row = gridCoord.y.toInt();
    final col = gridCoord.x.toInt();

    // Check if target is valid and occupied
    if (!scene.isValidGridPos(row, col) || !scene.occupiedGrid[row][col]) {  // ✅ FIXED: Remove underscore
      print('❌ Invalid hammer target');
      return false;
    }

    // Remove the block
    scene.occupiedGrid[row][col] = false;
    scene.placedBlocks[row][col] = null;

    // Remove visual component
    final targetPos = scene.gridPositions[row][col];
    for (final child in scene.children.toList()) {
      if (child is RectangleComponent && 
          child.position.distanceTo(targetPos) < 5 &&
          child.size.x == GameScene.cellSize) {
        scene.remove(child);
        break;
      }
    }

    print('🔨 Hammer destroyed block at ($row, $col)');
    AssetManager.playSfx('sfx_drop');
    return true;
  }

  // ✅ BOMB: Clear 3x3 area
  bool _executeBomb(GameScene scene, Vector2 targetPosition) {
    final gridCoord = scene.worldToGrid(targetPosition);  // ✅ FIXED: Remove underscore
    final centerRow = gridCoord.y.toInt();
    final centerCol = gridCoord.x.toInt();

    int blocksDestroyed = 0;

    // Clear 3x3 area around target
    for (int row = centerRow - 1; row <= centerRow + 1; row++) {
      for (int col = centerCol - 1; col <= centerCol + 1; col++) {
        if (scene.isValidGridPos(row, col) && scene.occupiedGrid[row][col]) {  // ✅ FIXED: Remove underscore
          scene.occupiedGrid[row][col] = false;
          scene.placedBlocks[row][col] = null;
          blocksDestroyed++;

          // Remove visual component
          final targetPos = scene.gridPositions[row][col];
          for (final child in scene.children.toList()) {
            if (child is RectangleComponent && 
                child.position.distanceTo(targetPos) < 5 &&
                child.size.x == GameScene.cellSize) {
              scene.remove(child);
              break;
            }
          }
        }
      }
    }

    print('💣 Bomb destroyed $blocksDestroyed blocks');
    AssetManager.playSfx('sfx_clear');
    return blocksDestroyed > 0;
  }

  // ✅ SHUFFLE: Replace current blocks
  bool _executeShuffle(GameScene scene) {
    // Remove current active blocks
    for (final block in scene.activeBlocks.toList()) {
      scene.remove(block);
    }
    scene.activeBlocks.clear();

    // Spawn new blocks
    scene.spawnThreeBlocks();

    print('🔄 Shuffled blocks');
    AssetManager.playSfx('sfx_click');
    return true;
  }

  // ✅ HINT: Show best placement
  bool _executeHint(GameScene scene) {
    if (scene.activeBlocks.isEmpty) return false;

    // Find best placement for first active block
    final block = scene.activeBlocks.first;
    Vector2? bestPosition;
    int maxClearPotential = 0;

    const int extendedGridSize = GameScene.extendedGridSize;
    
    for (int row = 1; row < extendedGridSize - 1; row++) {
      for (int col = 1; col < extendedGridSize - 1; col++) {
        final testPosition = scene.gridPositions[row][col];
        
        if (scene.canPlaceBlock(block, testPosition)) {
          final clearPotential = _calculateClearPotential(scene, block, row, col);
          if (clearPotential > maxClearPotential) {
            maxClearPotential = clearPotential;
            bestPosition = testPosition;
          }
        }
      }
    }

    if (bestPosition != null) {
      _showHintEffect(scene, bestPosition);
      print('💡 Hint showed best position');
      return true;
    }

    print('❌ No valid hint available');
    return false;
  }

  // ✅ Calculate potential lines that could be cleared
  int _calculateClearPotential(GameScene scene, BlockComponent block, int baseRow, int baseCol) {
    // Simulate placing the block and count potential clears
    final tempGrid = scene.occupiedGrid.map((row) => List<bool>.from(row)).toList();
    
    // Simulate block placement
    for (int shapeRow = 0; shapeRow < block.shape.length; shapeRow++) {
      for (int shapeCol = 0; shapeCol < block.shape[shapeRow].length; shapeCol++) {
        if (block.shape[shapeRow][shapeCol] == 1) {
          final gridRow = baseRow + shapeRow;
          final gridCol = baseCol + shapeCol;
          if (scene.isValidGridPos(gridRow, gridCol)) {
            tempGrid[gridRow][gridCol] = true;
          }
        }
      }
    }

    // Count potential line clears
    int clearPotential = 0;
    const int extendedGridSize = GameScene.extendedGridSize;

    // Check rows
    for (int row = 1; row < extendedGridSize - 1; row++) {
      bool isComplete = true;
      for (int col = 1; col < extendedGridSize - 1; col++) {
        if (!tempGrid[row][col]) {
          isComplete = false;
          break;
        }
      }
      if (isComplete) clearPotential += 10;
    }

    // Check columns
    for (int col = 1; col < extendedGridSize - 1; col++) {
      bool isComplete = true;
      for (int row = 1; row < extendedGridSize - 1; row++) {
        if (!tempGrid[row][col]) {
          isComplete = false;
          break;
        }
      }
      if (isComplete) clearPotential += 10;
    }

    return clearPotential;
  }

  // ✅ Show hint visual effect
  void _showHintEffect(GameScene scene, Vector2 position) {
    final hintIndicator = RectangleComponent(
      position: position,
      size: Vector2(GameScene.cellSize, GameScene.cellSize),
      paint: Paint()
        ..color = Colors.yellow.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Pulse effect
    hintIndicator.add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(duration: 0.5, alternate: true, infinite: true),
      ),
    );

    // Remove after 3 seconds
    hintIndicator.add(RemoveEffect(delay: 3.0));
    
    scene.add(hintIndicator);
  }

  // ✅ FREEZE: Pause game for thinking
  bool _executeFreeze(GameScene scene) {
    // Implement pause logic if needed
    print('❄️ Freeze activated - extra thinking time');
    AssetManager.playSfx('sfx_click');
    return true;
  }

  // ✅ Actually consume the power-up
  void _usePowerUp(PowerUpType type) {
    if (_inventory[type]! > 0) {
      _inventory[type] = _inventory[type]! - 1;
      print('✅ Used ${powerUps[type]!.name} (${_inventory[type]} remaining)');
    }
  }

  // ✅ Cancel active power-up
  void cancelActivePowerUp() {
    _activePowerUp = null;
    _waitingForTarget = false;
    print('❌ Power-up cancelled');
  }

  // ✅ Debug print inventory
  void printInventory() {
    print('🎒 POWER-UP INVENTORY:');
    for (final entry in _inventory.entries) {
      final data = powerUps[entry.key]!;
      print('   ${data.icon} ${data.name}: ${entry.value}');
    }
  }
}
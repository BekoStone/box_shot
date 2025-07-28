// File: lib/game/managers/undo_manager.dart - FIXED VERSION

// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import '../components/block_component.dart';

// ✅ FIXED: Better state snapshot with improved block identification
class UndoGameState {
  final List<List<bool>> occupiedGrid;
  final List<List<int>> blockIds;
  final Map<int, List<List<int>>> activeBlockShapes;
  final Map<int, Vector2> activeBlockPositions;
  final int score;
  final int level;
  final int linesCleared;
  final int comboCount;
  final int streakCount;
  final DateTime timestamp; // ✅ FIXED: Add timestamp for uniqueness

  UndoGameState({
    required this.occupiedGrid,
    required this.blockIds,
    required this.activeBlockShapes,
    required this.activeBlockPositions,
    required this.score,
    required this.level,
    required this.linesCleared,
    required this.comboCount,
    required this.streakCount,
    required this.timestamp,
  });

  // ✅ FIXED: Proper deep copy with timestamp preservation
  UndoGameState copy() {
    return UndoGameState(
      occupiedGrid: occupiedGrid.map((row) => List<bool>.from(row)).toList(),
      blockIds: blockIds.map((row) => List<int>.from(row)).toList(),
      activeBlockShapes: Map<int, List<List<int>>>.from(
        activeBlockShapes.map((key, value) => MapEntry(
          key, 
          value.map((row) => List<int>.from(row)).toList()
        ))
      ),
      activeBlockPositions: Map<int, Vector2>.from(
        activeBlockPositions.map((key, value) => MapEntry(key, value.clone()))
      ),
      score: score,
      level: level,
      linesCleared: linesCleared,
      comboCount: comboCount,
      streakCount: streakCount,
      timestamp: timestamp, // Preserve original timestamp
    );
  }
}

class UndoManager {
  static const int maxUndoStates = 5;
  
  final List<UndoGameState> _undoHistory = [];
  int _undoCount = 0;
  int _maxUndos = 3;
  int _nextBlockId = 1000; // ✅ FIXED: Start with a high number to avoid conflicts
  
  int get undoCount => _undoCount;
  int get remainingUndos => _maxUndos - _undoCount;
  bool get canUndo => _undoHistory.isNotEmpty && remainingUndos > 0;
  bool get hasUndoHistory => _undoHistory.isNotEmpty;
  
  // ✅ FIXED: Better unique ID generation using timestamp + counter
  int get nextBlockId {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueId = timestamp + _nextBlockId;
    _nextBlockId++;
    return uniqueId;
  }

  // ✅ FIXED: Improved state saving with better block identification
  void saveState({
    required List<List<bool>> occupiedGrid,
    required List<List<int>> blockIds,
    required List<BlockComponent> activeBlocks,
    required int score,
    required int level,
    required int linesCleared,
    required int comboCount,
    required int streakCount,
  }) {
    // ✅ FIXED: Create stable block IDs based on position and shape
    final Map<int, List<List<int>>> activeBlockShapes = {};
    final Map<int, Vector2> activeBlockPositions = {};
    
    for (int i = 0; i < activeBlocks.length; i++) {
      final block = activeBlocks[i];
      // ✅ FIXED: Use deterministic ID based on block index and current state
      final blockId = _generateStableBlockId(block, i);
      activeBlockShapes[blockId] = block.shape.map((row) => List<int>.from(row)).toList();
      activeBlockPositions[blockId] = block.originalPosition.clone();
    }

    final state = UndoGameState(
      occupiedGrid: occupiedGrid.map((row) => List<bool>.from(row)).toList(),
      blockIds: blockIds.map((row) => List<int>.from(row)).toList(),
      activeBlockShapes: activeBlockShapes,
      activeBlockPositions: activeBlockPositions,
      score: score,
      level: level,
      linesCleared: linesCleared,
      comboCount: comboCount,
      streakCount: streakCount,
      timestamp: DateTime.now(), // ✅ FIXED: Add timestamp
    );
    
    _undoHistory.add(state.copy());
    
    // Keep only the last N states to prevent memory issues
    if (_undoHistory.length > maxUndoStates) {
      _undoHistory.removeAt(0);
    }
    
    print('💾 Game state saved (${_undoHistory.length} states in history)');
    print('📊 State timestamp: ${state.timestamp.millisecondsSinceEpoch}');
  }

  // ✅ FIXED: Generate stable block IDs based on content and position
  int _generateStableBlockId(BlockComponent block, int index) {
    // Create a hash based on shape, position, and index
    int hash = index * 10000;
    
    // Add shape hash
    for (int row = 0; row < block.shape.length; row++) {
      for (int col = 0; col < block.shape[row].length; col++) {
        if (block.shape[row][col] == 1) {
          hash += (row * 100 + col * 10 + 1);
        }
      }
    }
    
    // Add position hash (rounded to avoid floating point issues)
    hash += (block.originalPosition.x.round() + block.originalPosition.y.round() * 1000);
    
    return hash.abs(); // Ensure positive ID
  }

  UndoGameState? performUndo() {
    if (!canUndo) {
      print('❌ Cannot undo: ${remainingUndos == 0 ? "No undos remaining" : "No history"}');
      return null;
    }

    final previousState = _undoHistory.removeLast();
    _undoCount++;
    
    print('↩️ Undo performed! (${remainingUndos} undos remaining)');
    print('📊 Restored state from: ${previousState.timestamp.millisecondsSinceEpoch}');
    return previousState;
  }

  void addUndos(int count) {
    _maxUndos += count;
    print('🎁 Added $count undos! Total available: $remainingUndos');
  }

  void resetForNewGame() {
    _undoHistory.clear();
    _undoCount = 0;
    _maxUndos = 3;
    _nextBlockId = 1000; // ✅ FIXED: Reset to safe starting value
    print('🔄 Undo manager reset for new game');
  }

  void enableUnlimitedUndos() {
    _maxUndos = 999999;
    print('👑 Unlimited undos enabled!');
  }

  Map<String, dynamic> getUndoStatus() {
    return {
      'canUndo': canUndo,
      'remainingUndos': remainingUndos,
      'totalUsed': _undoCount,
      'hasHistory': hasUndoHistory,
      'maxUndos': _maxUndos == 999999 ? 'Unlimited' : _maxUndos.toString(),
      'historySize': _undoHistory.length,
    };
  }

  void printStatus() {
    print('🔄 UNDO STATUS:');
    print('   History: ${_undoHistory.length} states');
    print('   Used: $_undoCount/$_maxUndos');
    print('   Can Undo: $canUndo');
    print('   Remaining: $remainingUndos');
    print('   Next Block ID: $_nextBlockId');
    
    // ✅ FIXED: Print state timestamps for debugging
    if (_undoHistory.isNotEmpty) {
      print('   Last saved: ${_undoHistory.last.timestamp.millisecondsSinceEpoch}');
    }
  }
}
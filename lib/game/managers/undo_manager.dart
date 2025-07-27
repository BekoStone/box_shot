// File: lib/game/managers/undo_manager.dart

// ignore_for_file: avoid_print

import 'package:flame/components.dart';
import '../components/block_component.dart';

// ✅ IMPROVED: Better state snapshot without component references
class UndoGameState {
  final List<List<bool>> occupiedGrid;
  final List<List<int>> blockIds; // Store block IDs instead of references
  final Map<int, List<List<int>>> activeBlockShapes; // Store shapes instead of components
  final Map<int, Vector2> activeBlockPositions; // Store positions
  final int score;
  final int level;
  final int linesCleared;
  final int comboCount;
  final int streakCount;
  final int nextBlockId; // Track next available block ID

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
    required this.nextBlockId,
  });

  // ✅ FIXED: Proper deep copy without component references
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
      nextBlockId: nextBlockId,
    );
  }
}

class UndoManager {
  static const int maxUndoStates = 5; // Keep last 5 moves
  
  final List<UndoGameState> _undoHistory = [];
  int _undoCount = 0; // Track how many undos used this game
  int _maxUndos = 3; // Default free undos per game
  int _nextBlockId = 0; // Track unique block IDs
  
  // ✅ Public getters
  int get undoCount => _undoCount;
  int get remainingUndos => _maxUndos - _undoCount;
  bool get canUndo => _undoHistory.isNotEmpty && remainingUndos > 0;
  bool get hasUndoHistory => _undoHistory.isNotEmpty;
  int get nextBlockId => _nextBlockId++;

  // ✅ IMPROVED: Save state without component references
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
    // Extract active block data without storing components
    final Map<int, List<List<int>>> activeBlockShapes = {};
    final Map<int, Vector2> activeBlockPositions = {};
    
    for (int i = 0; i < activeBlocks.length; i++) {
      final block = activeBlocks[i];
      final blockId = nextBlockId;
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
      nextBlockId: _nextBlockId,
    );
    
    _undoHistory.add(state.copy());
    
    // Keep only the last N states to prevent memory issues
    if (_undoHistory.length > maxUndoStates) {
      _undoHistory.removeAt(0);
    }
    
    print('💾 Game state saved (${_undoHistory.length} states in history)');
  }

  // ✅ Undo the last move
  UndoGameState? performUndo() {
    if (!canUndo) {
      print('❌ Cannot undo: ${remainingUndos == 0 ? "No undos remaining" : "No history"}');
      return null;
    }

    final previousState = _undoHistory.removeLast();
    _undoCount++;
    
    print('↩️ Undo performed! (${remainingUndos} undos remaining)');
    return previousState;
  }

  // ✅ Add extra undos via purchase/ads
  void addUndos(int count) {
    _maxUndos += count;
    print('🎁 Added $count undos! Total available: ${remainingUndos}');
  }

  // ✅ Reset for new game
  void resetForNewGame() {
    _undoHistory.clear();
    _undoCount = 0;
    _maxUndos = 3; // Reset to default free undos
    _nextBlockId = 0;
    print('🔄 Undo manager reset for new game');
  }

  // ✅ Premium/subscription: unlimited undos
  void enableUnlimitedUndos() {
    _maxUndos = 999999; // Effectively unlimited
    print('👑 Unlimited undos enabled!');
  }

  // ✅ Get undo status for UI
  Map<String, dynamic> getUndoStatus() {
    return {
      'canUndo': canUndo,
      'remainingUndos': remainingUndos,
      'totalUsed': _undoCount,
      'hasHistory': hasUndoHistory,
      'maxUndos': _maxUndos == 999999 ? 'Unlimited' : _maxUndos.toString(),
    };
  }

  // ✅ Debug method
  void printStatus() {
    print('🔄 UNDO STATUS:');
    print('   History: ${_undoHistory.length} states');
    print('   Used: $_undoCount/$_maxUndos');
    print('   Can Undo: $canUndo');
    print('   Remaining: $remainingUndos');
  }
}
// File: lib/game/managers/undo_manager.dart

// ignore_for_file: avoid_print

import '../components/block_component.dart';

// ✅ RENAMED to avoid conflict with existing GameState enum
class UndoGameState {
  final List<List<bool>> occupiedGrid;
  final List<List<BlockComponent?>> placedBlocks;
  final List<BlockComponent> activeBlocks;
  final int score;
  final int level;
  final int linesCleared;
  final int comboCount;
  final int streakCount;

  UndoGameState({
    required this.occupiedGrid,
    required this.placedBlocks,
    required this.activeBlocks,
    required this.score,
    required this.level,
    required this.linesCleared,
    required this.comboCount,
    required this.streakCount,
  });

  // ✅ Deep copy to prevent reference issues
  UndoGameState copy() {
    return UndoGameState(
      occupiedGrid: occupiedGrid.map((row) => List<bool>.from(row)).toList(),
      placedBlocks: placedBlocks.map((row) => List<BlockComponent?>.from(row)).toList(),
      activeBlocks: List<BlockComponent>.from(activeBlocks),
      score: score,
      level: level,
      linesCleared: linesCleared,
      comboCount: comboCount,
      streakCount: streakCount,
    );
  }
}

class UndoManager {
  static const int maxUndoStates = 5; // Keep last 5 moves
  
  final List<UndoGameState> _undoHistory = [];
  int _undoCount = 0; // Track how many undos used this game
  int _maxUndos = 3; // Default free undos per game
  
  // ✅ Public getters
  int get undoCount => _undoCount;
  int get remainingUndos => _maxUndos - _undoCount;
  bool get canUndo => _undoHistory.isNotEmpty && remainingUndos > 0;
  bool get hasUndoHistory => _undoHistory.isNotEmpty;

  // ✅ Save current game state before a move
  void saveState(UndoGameState state) {
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
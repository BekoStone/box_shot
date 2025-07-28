class ScoringManager {
  int _currentScore = 0;
  int _level = 1;
  int _linesCleared = 0;
  int _comboCount = 0;
  int _streakCount = 0;
  bool _lastClearWasDifficult = false;
  
  // ✅ Base scoring values (inspired by top puzzle games)
  static const Map<String, int> baseScores = {
    'block_place': 5,        // Points for placing each block
    'single_line': 100,      // 1 line cleared
    'double_line': 300,      // 2 lines cleared  
    'triple_line': 500,      // 3 lines cleared (rare but possible)
    'single_column': 100,    // 1 column cleared
    'double_column': 300,    // 2 columns cleared
    'line_and_column': 400,  // Line + column simultaneously
    'perfect_clear': 1000,   // Clear entire board section
  };
  
  // ✅ Combo multipliers (Tetris-inspired)
  static const List<double> comboMultipliers = [
    1.0,   // No combo
    1.2,   // 1 combo
    1.5,   // 2 combo  
    1.8,   // 3 combo
    2.2,   // 4 combo
    2.7,   // 5 combo
    3.3,   // 6 combo
    4.0,   // 7+ combo
  ];
  
  // ✅ Streak bonuses (Blockudoku-inspired)
  static const List<int> streakBonuses = [
    0,     // No streak
    50,    // 1 streak
    120,   // 2 streak
    200,   // 3 streak
    300,   // 4 streak
    450,   // 5 streak
    650,   // 6 streak
    900,   // 7+ streak
  ];

  // Getters
  int get currentScore => _currentScore;
  int get level => _level;
  int get linesCleared => _linesCleared;
  int get comboCount => _comboCount;
  int get streakCount => _streakCount;

  // ✅ Award points for placing a block
  void awardBlockPlacement(int blockCells) {
    final points = baseScores['block_place']! * blockCells * _level;
    _currentScore += points;
    
    print('🎯 Block placed: +$points points (${blockCells} cells × level $_level)');
  }

  // ✅ Award points for line clearing with advanced mechanics
  void awardLineClear({
    required int linesCleared,
    required int columnsCleared, 
    required int totalCellsCleared,
    bool isPerfectClear = false,
  }) {
    if (linesCleared == 0 && columnsCleared == 0) return;

    // 📊 Determine base score
    int baseScore = 0;
    String clearType = '';
    
    if (linesCleared > 0 && columnsCleared > 0) {
      // Both lines and columns cleared
      baseScore = baseScores['line_and_column']! * (linesCleared + columnsCleared);
      clearType = 'Line+Column';
      _lastClearWasDifficult = true;
    } else if (linesCleared > 0) {
      // Only lines cleared
      if (linesCleared == 1) {
        baseScore = baseScores['single_line']!;
        clearType = 'Single Line';
        _lastClearWasDifficult = false;
      } else if (linesCleared == 2) {
        baseScore = baseScores['double_line']!;
        clearType = 'Double Line';
        _lastClearWasDifficult = true;
      } else {
        baseScore = baseScores['triple_line']!;
        clearType = 'Triple Line';
        _lastClearWasDifficult = true;
      }
    } else {
      // Only columns cleared  
      if (columnsCleared == 1) {
        baseScore = baseScores['single_column']!;
        clearType = 'Single Column';
        _lastClearWasDifficult = false;
      } else {
        baseScore = baseScores['double_column']!;
        clearType = 'Double Column';
        _lastClearWasDifficult = true;
      }
    }

    // 🔥 Apply combo multiplier
    final comboIndex = (_comboCount).clamp(0, comboMultipliers.length - 1);
    final comboMultiplier = comboMultipliers[comboIndex];
    
    // ⚡ Apply streak bonus
    final streakIndex = (_streakCount).clamp(0, streakBonuses.length - 1);
    final streakBonus = streakBonuses[streakIndex];
    
    // 💎 Perfect clear bonus
    int perfectClearBonus = 0;
    if (isPerfectClear) {
      perfectClearBonus = baseScores['perfect_clear']! * _level;
    }
    
    // 🔄 Back-to-back bonus (50% extra for consecutive difficult clears)
    double backToBackMultiplier = 1.0;
    if (_lastClearWasDifficult && _comboCount > 0) {
      backToBackMultiplier = 1.5;
    }
    
    // 📈 Calculate final score
    final levelMultiplier = _level;
    final finalScore = ((baseScore * comboMultiplier * backToBackMultiplier).round() + 
                       streakBonus + perfectClearBonus) * levelMultiplier;
    
    _currentScore += finalScore;
    _linesCleared += linesCleared + columnsCleared;
    
    // 📊 Update counters
    _comboCount++;
    _streakCount++;
    _updateLevel();
    
    // 🎮 Debug output
    print('🎉 $clearType cleared!');
    print('   Base: $baseScore × Combo: ${comboMultiplier.toStringAsFixed(1)}x × Level: ${levelMultiplier}x');
    if (streakBonus > 0) print('   Streak Bonus: +$streakBonus');
    if (perfectClearBonus > 0) print('   Perfect Clear: +$perfectClearBonus');
    if (backToBackMultiplier > 1.0) print('   Back-to-Back: ${backToBackMultiplier}x');
    print('   Total: +$finalScore points');
    print('   Score: $_currentScore | Combo: $_comboCount | Streak: $_streakCount');
  }

  // ✅ Reset combo when no lines cleared
  void resetCombo() {
    if (_comboCount > 0) {
      print('💔 Combo broken! Was at $_comboCount');
    }
    _comboCount = 0;
    _lastClearWasDifficult = false;
  }

  // ✅ Reset streak when game gets difficult
  void resetStreak() {
    if (_streakCount > 0) {
      print('🔥 Streak ended! Was at $_streakCount');
    }
    _streakCount = 0;
  }

  // ✅ Level progression based on lines cleared
  void _updateLevel() {
    final newLevel = (_linesCleared ~/ 10) + 1; // Level up every 10 lines
    if (newLevel > _level) {
      _level = newLevel;
      print('🆙 LEVEL UP! Now at level $_level');
    }
  }

  // ✅ Get formatted score string
  String getFormattedScore() {
    return _currentScore.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // ✅ Get score breakdown for UI
  Map<String, dynamic> getScoreData() {
    return {
      'score': _currentScore,
      'level': _level,
      'lines': _linesCleared,
      'combo': _comboCount,
      'streak': _streakCount,
      'formattedScore': getFormattedScore(),
    };
  }

  // ✅ Reset everything for new game
  void reset() {
    _currentScore = 0;
    _level = 1;
    _linesCleared = 0;
    _comboCount = 0;
    _streakCount = 0;
    _lastClearWasDifficult = false;
    print('🔄 Score reset for new game');
  }
  
  // ✅ NEW: Restore state for undo functionality
  void restoreState(int score, int level, int linesCleared, int comboCount, int streakCount) {
    _currentScore = score;
    _level = level;
    _linesCleared = linesCleared;
    _comboCount = comboCount;
    _streakCount = streakCount;
    print('↩️ Score state restored: $score points, level $level');
  }
}
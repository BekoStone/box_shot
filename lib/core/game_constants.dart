// File: lib/core/game_constants.dart

class GameConstants {
  // Grid Configuration
  static const int gridSize = 8;
  static const int extendedGridSize = gridSize + 2;
  static const double cellSize = 36.0;
  static const double spacing = 3.0;
  
  // UI Dimensions
  static const double slotWidth = 90.0;
  static const double slotHeight = 90.0;
  static const double powerUpPanelWidth = 80.0;
  static const double buttonHeight = 70.0;
  static const double buttonSpacing = 10.0;
  
  // Game Mechanics
  static const int maxUndos = 3;
  static const int maxUndoStates = 5;
  static const double collisionTolerance = 1.0;
  static const double precisionTolerance = 0.1;
  
  // Scoring
  static const int baseBlockScore = 5;
  static const int singleLineScore = 100;
  static const int doubleLineScore = 300;
  static const int tripleLineScore = 500;
  static const int perfectClearScore = 1000;
  
  // Coins
  static const int startingCoins = 100;
  static const int blockPlacementCoins = 1;
  static const int lineClearCoins = 10;
  static const int dailyBonusCoins = 25;
  static const int adRewardCoins = 50;
  
  // Power-up Costs
  static const Map<String, int> powerUpPrices = {
    'hammer': 50,
    'bomb': 100,
    'shuffle': 75,
    'hint': 25,
    'freeze': 30,
  };
  
  // Animation Durations
  static const double shortAnimationDuration = 0.3;
  static const double mediumAnimationDuration = 0.5;
  static const double longAnimationDuration = 1.0;
  
  // Game Balance
  static const int linesPerLevel = 10;
  static const double gameDangerThreshold = 70.0; // Grid fill percentage
  static const int lowMovesWarning = 5;
}
// File: lib/ui/overlays/enhanced_game_over_overlay.dart

import 'package:flutter/material.dart';

class EnhancedGameOverOverlay extends StatelessWidget {
  final int finalScore;
  final int level;
  final int linesCleared;
  final double gridFillPercentage;
  final int coinsEarned;
  final List<String> achievementsUnlocked;
  final bool canUndo;
  final int undoCount;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  final VoidCallback onShare;
  final VoidCallback? onUndo; // NEW: Undo from game over!
  final VoidCallback? onWatchAd; // NEW: Watch ad for coins
  final VoidCallback? onBuyPowerUps; // NEW: Quick power-up purchase

  const EnhancedGameOverOverlay({
    super.key,
    required this.finalScore,
    required this.level,
    required this.linesCleared,
    required this.gridFillPercentage,
    required this.coinsEarned,
    required this.achievementsUnlocked,
    required this.canUndo,
    required this.undoCount,
    required this.onRestart,
    required this.onMainMenu,
    required this.onShare,
    this.onUndo,
    this.onWatchAd,
    this.onBuyPowerUps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 40, 119, 230),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ GAME OVER HEADER WITH ANIMATION POTENTIAL
                const Text(
                  "GAME OVER",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ ACHIEVEMENT NOTIFICATION (if any)
                if (achievementsUnlocked.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "🏆 ACHIEVEMENT UNLOCKED!",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        ...achievementsUnlocked.map((achievement) => Text(
                          achievement,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        )).take(2), // Show max 2 achievements
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                // ✅ FINAL SCORE - Enhanced Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "FINAL SCORE",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatScore(finalScore),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // ✅ NEW: Coins earned display
                      if (coinsEarned > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "💰 +$coinsEarned coins earned",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ ENHANCED GAME STATISTICS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "GAME STATISTICS",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("Level", level.toString()),
                          _buildStatItem("Lines", linesCleared.toString()),
                          _buildStatItem("Grid Fill", "${gridFillPercentage.toStringAsFixed(1)}%"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // ✅ GAME-CHANGING ADDITION: UNDO OPTION FROM GAME OVER!
                if (canUndo && onUndo != null) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                      onPressed: onUndo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.undo, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "UNDO LAST MOVE ($undoCount left)",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ✅ PRIMARY ACTION BUTTONS
                Column(
                  children: [
                    // Play Again Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restart_alt, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "PLAY AGAIN",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ✅ NEW: MONETIZATION ROW
                    Row(
                      children: [
                        // Watch Ad for Coins
                        if (onWatchAd != null)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onWatchAd,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_fill, size: 20),
                                  SizedBox(height: 2),
                                  Text(
                                    "AD +50",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (onWatchAd != null && onBuyPowerUps != null) 
                          const SizedBox(width: 10),

                        // Quick Power-up Purchase
                        if (onBuyPowerUps != null)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onBuyPowerUps,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_cart, size: 20),
                                  SizedBox(height: 2),
                                  Text(
                                    "POWER-UPS",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Secondary Buttons Row
                    Row(
                      children: [
                        // Share Score Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onShare,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "SHARE",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Main Menu Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onMainMenu,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "MENU",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ✅ NEW: RETENTION HOOK - "You're close to achievement!"
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.lightBlue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "💡 Tip: You're 2 games away from 'Getting Started' achievement!",
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Helper: Build individual stat items with better styling
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ✅ Helper: Format score with commas
  String _formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
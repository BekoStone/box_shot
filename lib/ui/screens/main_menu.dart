import 'package:flutter/material.dart';
import '../../core/theme.dart';  // ✅ FIXED: Now exists
import '../../core/assets.dart'; // ✅ FIXED: Updated assets

class MainMenuScreen extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onReward;
  final VoidCallback onShop;
  final VoidCallback onSettings;

  const MainMenuScreen({
    super.key,
    required this.onPlay,
    required this.onReward,
    required this.onShop,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Background with gradient (matches logo colors)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB), // Light blue (matching logo)
                Color(0xFF4682B4), // Steel blue
              ],
            ),
          ),
        ),
        
        // ✅ Alternative: Use background image if available
        // Image.asset(
        //   Assets.bgMainMenu,
        //   fit: BoxFit.cover,
        //   width: double.infinity,
        //   height: double.infinity,
        //   errorBuilder: (context, error, stackTrace) {
        //     // Fallback to gradient if image fails to load
        //     return const SizedBox.shrink();
        //   },
        // ),
        
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ NEW: Use the beautiful Box Hooks logo
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  Assets.logoMain, // Use the main logo (Image 1)
                  width: 280,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // ✅ Fallback to text if logo fails to load
                    return Text(
                      "BOX HOOKS",
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 42,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withAlpha(77),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              
              // ✅ Game buttons with improved styling
              MenuButton(
                text: "PLAY",
                onPressed: onPlay,
                backgroundColor: const Color(0xFF4CAF50), // Green
                icon: Icons.play_arrow,
              ),
              const SizedBox(height: 20),
              
              MenuButton(
                text: "DAILY REWARD",
                onPressed: onReward,
                backgroundColor: const Color(0xFFFF9800), // Orange
                icon: Icons.card_giftcard,
              ),
              const SizedBox(height: 20),
              
              MenuButton(
                text: "SHOP",
                onPressed: onShop,
                backgroundColor: const Color(0xFF9C27B0), // Purple
                icon: Icons.shopping_cart,
              ),
            ],
          ),
        ),
        
        // ✅ Settings button (top-right)
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(51),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: onSettings,
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 30,
              ),
              tooltip: 'Settings',
            ),
          ),
        ),
      ],
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData? icon;

  const MenuButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Fixed width for consistency
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          backgroundColor: backgroundColor ?? const Color.fromARGB(255, 28, 150, 215),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withAlpha(77),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
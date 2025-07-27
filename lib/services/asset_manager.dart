// File: lib/services/asset_manager.dart

// ignore_for_file: avoid_print

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

class AssetManager {
  static Future<void> preloadAssets() async {
    try {
      // ✅ FIXED: Correct image paths matching pubspec.yaml structure
      await Flame.images.loadAll([
        'ui/logo.png',              // For splash screen
        'ui/icon_star.png',         // For rewards/achievements  
        'ui/icon_coin.png',         // For shop/currency
        'backgrounds/bg_mainmenu.jpg', // Main menu background
      ]);

      // ✅ FIXED: Correct audio paths matching pubspec.yaml structure  
      await FlameAudio.audioCache.loadAll([
        // Sound Effects
        'sfx/sfx_drop.mp3',         // Block placement
        'sfx/sfx_clear.mp3',        // Line clearing
        'sfx/sfx_error.mp3',        // Invalid placement
        'sfx/sfx_click.mp3',        // UI interactions
        'sfx/sfx_combo.mp3',        // Combo achievements
        'sfx/sfx_win.mp3',          // Level completion
        'sfx/sfx_lose.mp3',         // Game over
        'sfx/sfx_reward.mp3',       // Daily reward claim
        
        // Background Music
        'music/music_menu.mp3',     // Main menu music
        'music/music_game.mp3',     // Gameplay music
      ]);

      print('✅ All assets preloaded successfully');
    } catch (e) {
      print('❌ Asset loading failed: $e');
      // ✅ IMPROVED: Graceful fallback for missing assets
      print('🔄 Continuing without problematic assets...');
    }
  }

  // ✅ NEW: Individual asset loading with error handling
  static Future<bool> loadImage(String path) async {
    try {
      await Flame.images.load(path);
      return true;
    } catch (e) {
      print('❌ Failed to load image: $path - $e');
      return false;
    }
  }

  static Future<bool> loadAudio(String path) async {
    try {
      await FlameAudio.audioCache.load(path);
      return true;
    } catch (e) {
      print('❌ Failed to load audio: $path - $e');
      return false;
    }
  }

  // ✅ SIMPLIFIED: Check if assets exist before using them
  static bool hasImage(String path) {
    try {
      return Flame.images.fromCache(path) != null;
    } catch (e) {
      return false;
    }
  }

  static bool hasAudio(String path) {
    // ✅ SIMPLIFIED: Just try to play, handle errors gracefully
    return true; // Assume audio exists, handle errors in play methods
  }

  // ✅ NEW: Safe asset usage methods
  static void playSfx(String name) {
    // ✅ FIX: Handle both 'sfx_click' and full path formats
    final path = name.contains('.mp3') ? name : 'sfx/$name.mp3';
    
    if (hasImage(path) || hasAudio(path)) {
      try {
        FlameAudio.play(path, volume: 0.7);
      } catch (e) {
        print('🔇 Failed to play SFX: $name - $e');
      }
    } else {
      print('🔇 SFX not available: $name');
    }
  }

  static void playMusic(String name, {bool loop = true}) {
    // ✅ FIX: Handle both 'music_menu' and full path formats  
    final path = name.contains('.mp3') ? name : 'music/$name.mp3';
    
    if (hasAudio(path)) {
      try {
        FlameAudio.bgm.play(path, volume: 0.5);
      } catch (e) {
        print('🔇 Failed to play music: $name - $e');
      }
    } else {
      print('🔇 Music not available: $name');
    }
  }

  static void stopMusic() {
    FlameAudio.bgm.stop();
  }
}
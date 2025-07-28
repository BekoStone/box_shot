// File: lib/services/asset_manager.dart - FIXED VERSION

// ignore_for_file: avoid_print

import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

class AssetManager {
  // ✅ FIXED: Track loaded assets for better error handling
  static final Set<String> _loadedImages = {};
  static final Set<String> _loadedAudio = {};
  static bool _audioEnabled = true;
  static bool _musicEnabled = true;

  static Future<void> preloadAssets() async {
    try {
      print('🔄 Starting asset preload...');
      
      // Load images with individual error handling
      final imageAssets = [
        'ui/logo.png',
        'ui/icon_star.png',
        'ui/icon_coin.png',
        'backgrounds/bg_mainmenu.jpg',
      ];

      for (final imagePath in imageAssets) {
        final success = await loadImage(imagePath);
        if (success) {
          _loadedImages.add(imagePath);
        }
      }

      // Load audio with individual error handling
      final audioAssets = [
        // Sound Effects
        'sfx/sfx_drop.mp3',
        'sfx/sfx_clear.mp3',
        'sfx/sfx_error.mp3',
        'sfx/sfx_click.mp3',
        'sfx/sfx_combo.mp3',
        'sfx/sfx_win.mp3',
        'sfx/sfx_lose.mp3',
        'sfx/sfx_reward.mp3',
        
        // Background Music
        'music/music_menu.mp3',
        'music/music_game.mp3',
      ];

      for (final audioPath in audioAssets) {
        final success = await loadAudio(audioPath);
        if (success) {
          _loadedAudio.add(audioPath);
        }
      }

      print('✅ Asset preload completed');
      print('📊 Loaded images: ${_loadedImages.length}/${imageAssets.length}');
      print('📊 Loaded audio: ${_loadedAudio.length}/${audioAssets.length}');

    } catch (e) {
      print('❌ Asset loading failed: $e');
      print('🔄 Continuing with available assets...');
    }
  }

  // ✅ FIXED: Improved individual asset loading with proper error handling
  static Future<bool> loadImage(String path) async {
    try {
      await Flame.images.load(path);
      print('✅ Loaded image: $path');
      return true;
    } catch (e) {
      print('❌ Failed to load image: $path - $e');
      return false;
    }
  }

  static Future<bool> loadAudio(String path) async {
    try {
      await FlameAudio.audioCache.load(path);
      print('✅ Loaded audio: $path');
      return true;
    } catch (e) {
      print('❌ Failed to load audio: $path - $e');
      return false;
    }
  }

  // ✅ FIXED: Proper asset existence checking
  static bool hasImage(String path) {
    try {
      final image = Flame.images.fromCache(path);
      return image != null && _loadedImages.contains(path);
    } catch (e) {
      return false;
    }
  }

  // ✅ FIXED: Proper audio existence checking
  static bool hasAudio(String path) {
    return _loadedAudio.contains(path);
  }

  // ✅ FIXED: Enhanced audio playing with proper error handling
  static void playSfx(String name) {
    if (!_audioEnabled) {
      print('🔇 SFX disabled');
      return;
    }

    // Handle both 'sfx_click' and full path formats
    final path = name.contains('.mp3') ? name : 'sfx/$name.mp3';
    
    if (!hasAudio(path)) {
      print('🔇 SFX not available: $name');
      return;
    }

    try {
      FlameAudio.play(path, volume: 0.7);
      print('🔊 Played SFX: $name');
    } catch (e) {
      print('🔇 Failed to play SFX: $name - $e');
      // Remove from loaded list if it fails to play
      _loadedAudio.remove(path);
    }
  }

  static void playMusic(String name, {bool loop = true}) {
    if (!_musicEnabled) {
      print('🔇 Music disabled');
      return;
    }

    // Handle both 'music_menu' and full path formats
    final path = name.contains('.mp3') ? name : 'music/$name.mp3';
    
    if (!hasAudio(path)) {
      print('🔇 Music not available: $name');
      return;
    }

    try {
      FlameAudio.bgm.play(path, volume: 0.5);
      print('🎵 Playing music: $name');
    } catch (e) {
      print('🔇 Failed to play music: $name - $e');
      // Remove from loaded list if it fails to play
      _loadedAudio.remove(path);
    }
  }

  static void stopMusic() {
    try {
      FlameAudio.bgm.stop();
      print('🎵 Music stopped');
    } catch (e) {
      print('🔇 Failed to stop music: $e');
    }
  }

  // ✅ NEW: Audio control methods with proper state management
  static void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    print('🔊 SFX ${enabled ? "enabled" : "disabled"}');
    
    if (!enabled) {
      // Stop any currently playing SFX if possible
      // Note: FlameAudio doesn't have a direct way to stop all SFX
    }
  }

  static void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    print('🎵 Music ${enabled ? "enabled" : "disabled"}');
    
    if (!enabled) {
      stopMusic();
    }
  }

  static bool get isAudioEnabled => _audioEnabled;
  static bool get isMusicEnabled => _musicEnabled;

  // ✅ NEW: Get asset loading status
  static Map<String, dynamic> getAssetStatus() {
    return {
      'imagesLoaded': _loadedImages.length,
      'audioLoaded': _loadedAudio.length,
      'audioEnabled': _audioEnabled,
      'musicEnabled': _musicEnabled,
      'loadedImages': _loadedImages.toList(),
      'loadedAudio': _loadedAudio.toList(),
    };
  }

  // ✅ NEW: Preload additional assets on demand
  static Future<bool> loadAssetOnDemand(String path, {bool isAudio = false}) async {
    if (isAudio) {
      if (_loadedAudio.contains(path)) {
        return true; // Already loaded
      }
      final success = await loadAudio(path);
      if (success) {
        _loadedAudio.add(path);
      }
      return success;
    } else {
      if (_loadedImages.contains(path)) {
        return true; // Already loaded
      }
      final success = await loadImage(path);
      if (success) {
        _loadedImages.add(path);
      }
      return success;
    }
  }

  // ✅ NEW: Cleanup method for memory management
  static void clearCache() {
    try {
      Flame.images.clearCache();
      FlameAudio.audioCache.clearAll();
      _loadedImages.clear();
      _loadedAudio.clear();
      print('🗑️ Asset cache cleared');
    } catch (e) {
      print('❌ Failed to clear cache: $e');
    }
  }
}
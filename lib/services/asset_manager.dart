import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

class AssetManager {
  static Future<void> preloadAssets() async {
    await Flame.images.loadAll([
      'ui/logo.png',
      'ui/icon_star.png',
      'ui/icon_coin.png',
      'backgrounds/bg_mainmenu.jpg',
    ]);

    await FlameAudio.audioCache.loadAll([
      'sfx/sfx_drop.mp3',
      'sfx/sfx_clear.mp3',
      'sfx/sfx_error.mp3',
      'sfx/sfx_click.mp3',
      'sfx/sfx_combo.mp3',
      'sfx/sfx_win.mp3',
      'sfx/sfx_lose.mp3',
      'sfx/sfx_reward.mp3',
      'music/music_menu.mp3',
      'music/music_game.mp3',
    ]);
  }
}

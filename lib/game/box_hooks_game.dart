import 'package:flame/game.dart';
import 'package:flame/events.dart';
import '../services/asset_manager.dart';
import 'game_state.dart';
import 'components/game_scene.dart';

class BoxHooksGame extends FlameGame with DragCallbacks, TapCallbacks , HasCollisionDetection {
  GameState currentState = GameState.splash;

  late final GameScene _gameScene;

  @override
  Future<void> onLoad() async {
    await AssetManager.preloadAssets();
    _gameScene = GameScene(); // تحضير شاشة اللعب
  }

  void showMainMenu() {
    overlays.remove('AnimatedSplash');
    overlays.add('MainMenu');
    currentState = GameState.menu;
  }

  void startGame() {
    overlays.remove('MainMenu');
    add(_gameScene);
    currentState = GameState.playing;
  }

  void claimDailyReward() {
    // لاحقاً: تنفيذ نافذة الجوائز اليومية
  }

  void openShop() {
    // لاحقاً: فتح المتجر
  }

  void openSettings() {
    // لاحقاً: الإعدادات
  }
}

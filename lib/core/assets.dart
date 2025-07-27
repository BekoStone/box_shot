// File: lib/core/assets.dart

class Assets {
  // ✅ Background Images
  static const bgMainMenu = 'backgrounds/bg_mainmenu.jpg';
  
  // ✅ UI Icons
  static const iconStar = 'ui/icon_star.png';
  static const iconCoin = 'ui/icon_coin.png';
  static const logo = 'ui/logo.png';
  
  // ✅ NEW: Game logos (add these to assets/images/ui/ folder)
  static const logoMain = 'ui/box_hooks_logo_main.png';     // Image 1: Main logo
  static const logoIcon = 'ui/box_hooks_icon.png';          // Image 2: App icon  
  static const logoCompact = 'ui/box_hooks_logo_compact.png'; // Image 3: Compact logo
  
  // ✅ Audio Assets - Sound Effects
  static const sfxDrop = 'sfx/sfx_drop.mp3';
  static const sfxClear = 'sfx/sfx_clear.mp3';
  static const sfxError = 'sfx/sfx_error.mp3';
  static const sfxClick = 'sfx/sfx_click.mp3';
  static const sfxCombo = 'sfx/sfx_combo.mp3';
  static const sfxWin = 'sfx/sfx_win.mp3';
  static const sfxLose = 'sfx/sfx_lose.mp3';
  static const sfxReward = 'sfx/sfx_reward.mp3';
  
  // ✅ Audio Assets - Background Music
  static const musicMenu = 'music/music_menu.mp3';
  static const musicGame = 'music/music_game.mp3';
  
  // ✅ Asset validation helper
  static const List<String> requiredImages = [
    bgMainMenu,
    iconStar,
    iconCoin,
    logo,
  ];
  
  static const List<String> requiredAudio = [
    sfxDrop,
    sfxClear,
    sfxError,
    sfxClick,
    musicMenu,
    musicGame,
  ];
}
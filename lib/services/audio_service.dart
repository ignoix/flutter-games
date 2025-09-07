import 'package:audioplayers/audioplayers.dart';

/// 音效服务类
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;

  /// 是否启用音效
  bool get isEnabled => _isEnabled;

  /// 切换音效开关
  void toggleAudio() {
    _isEnabled = !_isEnabled;
  }

  /// 播放摸牌音效
  Future<void> playDrawTileSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/draw_tile.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放打牌音效
  Future<void> playDiscardTileSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/discard_tile.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放胡牌音效
  Future<void> playWinSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/win.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放碰牌音效
  Future<void> playPengSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/peng.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放杠牌音效
  Future<void> playGangSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/gang.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放吃牌音效
  Future<void> playChiSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/chi.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放按钮点击音效
  Future<void> playButtonClickSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/button_click.mp3'));
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 播放背景音乐
  Future<void> playBackgroundMusic() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/background_music.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // 音效文件不存在时静默处理
    }
  }

  /// 停止背景音乐
  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }

  /// 释放资源
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}


import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/settings.dart';
import 'settings_provider.dart';

final audioProvider = Provider<AudioController>((ref) {
  final controller = AudioController();

  // Apply initial settings immediately
  final settings = ref.read(settingsProvider);
  controller.applySettings(
    musicOn: settings.musicOn,
    soundOn: settings.soundOn,
  );

  // React to settings changes going forward
  ref.listen<GameSettings>(settingsProvider, (previous, next) {
    if (previous?.musicOn != next.musicOn ||
        previous?.soundOn != next.soundOn) {
      controller.applySettings(
        musicOn: next.musicOn,
        soundOn: next.soundOn,
      );
    }
  });

  ref.onDispose(controller.dispose);
  return controller;
});

class AudioController {
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isBgPlaying = false;
  bool _soundOn = true;

  AudioController() {
    _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Applies music and sound toggles from settings.
  void applySettings({required bool musicOn, required bool soundOn}) async {
    _soundOn = soundOn;

    // Background music
    if (musicOn) {
      if (!_isBgPlaying) {
        try {
          await _bgMusicPlayer.setVolume(0.15);
          await _bgMusicPlayer.play(AssetSource('audio/bg_music.wav'));
          _isBgPlaying = true;
        } catch (_) {}
      } else {
        await _bgMusicPlayer.setVolume(0.15);
      }
    } else {
      if (_isBgPlaying) {
        try {
          await _bgMusicPlayer.pause();
          _isBgPlaying = false;
        } catch (_) {}
      }
    }

    // SFX volume
    await _sfxPlayer.setVolume(soundOn ? 1.0 : 0.0);
  }

  Future<void> playClick() async {
    if (!_soundOn) return;
    try {
      await _sfxPlayer.play(
        AssetSource('audio/click.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  Future<void> playPour() async {
    if (!_soundOn) return;
    try {
      await _sfxPlayer.play(
        AssetSource('audio/pour.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  Future<void> playWin() async {
    if (!_soundOn) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/win.wav'));
    } catch (_) {}
  }

  void dispose() {
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

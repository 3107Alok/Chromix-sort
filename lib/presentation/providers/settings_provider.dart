import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/settings.dart';
import 'storage_provider.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, GameSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<GameSettings> {
  @override
  GameSettings build() {
    // Load synchronously from Hive on first build
    return ref.read(storageProvider).loadSettings();
  }

  Future<void> toggleMusic() async {
    state = state.copyWith(musicOn: !state.musicOn);
    await ref.read(storageProvider).saveSettings(state);
  }

  Future<void> toggleSound() async {
    state = state.copyWith(soundOn: !state.soundOn);
    await ref.read(storageProvider).saveSettings(state);
  }

  Future<void> toggleHaptic() async {
    state = state.copyWith(hapticOn: !state.hapticOn);
    await ref.read(storageProvider).saveSettings(state);
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    await ref.read(storageProvider).saveSettings(state);
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    await ref.read(storageProvider).saveSettings(state);
  }
}

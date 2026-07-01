import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/settings.dart';
import '../../domain/models/user_stats.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/game_state.dart';

class HiveStorage {
  static const String _boxName = 'bottlesort_storage';
  static const String _settingsKey = 'settings';
  static const String _statsKey = 'stats';
  static const String _gameStateKey = 'game_state';
  static const String _achievementsKey = 'achievements';

  late Box _box;

  /// Initializes Hive and opens the storage box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // === SETTINGS ===
  Future<void> saveSettings(GameSettings settings) async {
    final jsonStr = jsonEncode(settings.toJson());
    await _box.put(_settingsKey, jsonStr);
  }

  GameSettings loadSettings() {
    final jsonStr = _box.get(_settingsKey) as String?;
    if (jsonStr == null) return const GameSettings();
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameSettings.fromJson(jsonMap);
    } catch (_) {
      return const GameSettings();
    }
  }

  // === STATS ===
  Future<void> saveStats(UserStats stats) async {
    final jsonStr = jsonEncode(stats.toJson());
    await _box.put(_statsKey, jsonStr);
  }

  UserStats loadStats() {
    final jsonStr = _box.get(_statsKey) as String?;
    if (jsonStr == null) return const UserStats();
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserStats.fromJson(jsonMap);
    } catch (_) {
      return const UserStats();
    }
  }

  // === GAME STATE (FOR AUTO-SAVE / RESUME) ===
  Future<void> saveGameState(GameState state) async {
    final jsonStr = jsonEncode(state.toJson());
    await _box.put(_gameStateKey, jsonStr);
  }

  GameState? loadGameState() {
    final jsonStr = _box.get(_gameStateKey) as String?;
    if (jsonStr == null) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameState.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGameState() async {
    await _box.delete(_gameStateKey);
  }

  // === ACHIEVEMENTS ===
  Future<void> saveAchievements(List<Achievement> achievements) async {
    final list = achievements.map((a) => a.toJson()).toList();
    final jsonStr = jsonEncode(list);
    await _box.put(_achievementsKey, jsonStr);
  }

  List<Achievement> loadAchievements() {
    final jsonStr = _box.get(_achievementsKey) as String?;
    if (jsonStr == null) return Achievement.defaultAchievements;
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((item) => Achievement.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return Achievement.defaultAchievements;
    }
  }

  // === RESET ALL PROGRESS ===
  Future<void> resetAll() async {
    await _box.clear();
  }
}

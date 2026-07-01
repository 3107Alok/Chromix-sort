import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_stats.dart';
import 'storage_provider.dart';

final statsProvider = NotifierProvider<StatsNotifier, UserStats>(
  StatsNotifier.new,
);

class StatsNotifier extends Notifier<UserStats> {
  @override
  UserStats build() {
    // Load synchronously from Hive on first build
    return ref.read(storageProvider).loadStats();
  }

  Future<void> _save(UserStats newStats) async {
    state = newStats;
    await ref.read(storageProvider).saveStats(newStats);
  }

  Future<void> incrementMoves(int count) async {
    await _save(state.copyWith(totalMoves: state.totalMoves + count));
  }

  Future<void> incrementHintsUsed() async {
    await _save(state.copyWith(totalHintsUsed: state.totalHintsUsed + 1));
  }

  Future<void> addPlayTime(int seconds) async {
    await _save(state.copyWith(totalPlayTime: state.totalPlayTime + seconds));
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;
    await _save(state.copyWith(coins: state.coins - amount));
    return true;
  }

  Future<void> addCoins(int amount) async {
    await _save(state.copyWith(coins: state.coins + amount));
  }

  /// Called when a regular level is successfully completed.
  Future<void> levelCompleted(int levelNum, int movesCount) async {
    final completedList = List<int>.from(state.completedLevels);
    if (!completedList.contains(levelNum)) {
      completedList.add(levelNum);
    }

    final newLevel =
        levelNum == state.currentLevel ? state.currentLevel + 1 : state.currentLevel;

    // Calculate daily streak
    final today = _getTodayDateString();
    int newCurrentStreak = state.currentStreak;

    if (state.lastPlayedDate.isEmpty) {
      newCurrentStreak = 1;
    } else {
      final lastDate = DateTime.tryParse(state.lastPlayedDate);
      if (lastDate != null) {
        final difference = DateTime.now().difference(lastDate).inDays;
        if (difference == 1) {
          newCurrentStreak += 1;
        } else if (difference > 1) {
          newCurrentStreak = 1;
        }
      }
    }

    final newBestStreak =
        newCurrentStreak > state.bestStreak ? newCurrentStreak : state.bestStreak;

    await _save(state.copyWith(
      currentLevel: newLevel,
      completedLevels: completedList,
      totalMoves: state.totalMoves + movesCount,
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
      lastPlayedDate: today,
      coins: state.coins + 20, // Base reward
    ));
  }

  /// Called when a daily challenge is successfully completed.
  Future<void> dailyChallengeCompleted(String dateString) async {
    final completedDailies = List<String>.from(state.completedDailies);
    if (!completedDailies.contains(dateString)) {
      completedDailies.add(dateString);
    }
    await _save(state.copyWith(
      completedDailies: completedDailies,
      coins: state.coins + 100,
    ));
  }

  /// Resets stats to initial state.
  Future<void> resetStats() async {
    await _save(const UserStats());
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

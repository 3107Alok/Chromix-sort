import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/user_stats.dart';
import 'storage_provider.dart';
import 'stats_provider.dart';

final achievementsProvider =
    NotifierProvider<AchievementsNotifier, List<Achievement>>(
  AchievementsNotifier.new,
);

class AchievementsNotifier extends Notifier<List<Achievement>> {
  @override
  List<Achievement> build() {
    // Load synchronously from Hive on first build
    return ref.read(storageProvider).loadAchievements();
  }

  Future<void> _save() async {
    await ref.read(storageProvider).saveAchievements(state);
  }

  /// Reactively evaluates achievements against the latest [UserStats].
  Future<void> evaluateStats(UserStats stats) async {
    bool changed = false;

    final updatedList = state.map((achievement) {
      if (achievement.isUnlocked) return achievement;

      int newVal = achievement.currentValue;
      bool newUnlocked = false;

      switch (achievement.id) {
        case 'first_level':
          newVal = stats.totalLevelsCompleted;
          if (newVal >= 1) newUnlocked = true;
          break;
        case 'ten_levels':
          newVal = stats.totalLevelsCompleted;
          if (newVal >= 10) newUnlocked = true;
          break;
        case 'fifty_levels':
          newVal = stats.totalLevelsCompleted;
          if (newVal >= 50) newUnlocked = true;
          break;
        case 'first_hint':
          newVal = stats.totalHintsUsed;
          if (newVal >= 1) newUnlocked = true;
          break;
        case 'streak_3':
          newVal = stats.bestStreak;
          if (newVal >= 3) newUnlocked = true;
          break;
        default:
          break;
      }

      if (newVal != achievement.currentValue ||
          newUnlocked != achievement.isUnlocked) {
        changed = true;
        if (newUnlocked && !achievement.isUnlocked) {
          ref.read(statsProvider.notifier).addCoins(achievement.rewardCoins);
        }
        return achievement.copyWith(
          currentValue: newVal,
          isUnlocked: newUnlocked,
        );
      }
      return achievement;
    }).toList();

    if (changed) {
      state = updatedList;
      await _save();
    }
  }

  /// Triggers a one-shot action-based achievement by ID.
  Future<void> triggerAchievementAction(String id) async {
    bool changed = false;
    final updatedList = state.map((achievement) {
      if (achievement.id == id && !achievement.isUnlocked) {
        changed = true;
        ref.read(statsProvider.notifier).addCoins(achievement.rewardCoins);
        return achievement.copyWith(
          currentValue: achievement.targetValue,
          isUnlocked: true,
        );
      }
      return achievement;
    }).toList();

    if (changed) {
      state = updatedList;
      await _save();
    }
  }

  Future<void> resetAchievements() async {
    state = Achievement.defaultAchievements;
    await _save();
  }
}

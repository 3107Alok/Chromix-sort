import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/achievements_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);

    return BackgroundWidget(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {
                    ref.read(audioProvider).playClick();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Scrollable Achievements list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: GameTheme.glassDecoration(
                      borderRadius: 18,
                      color: achievement.isUnlocked
                          ? GameTheme.accentGlow.withOpacity(0.08)
                          : Colors.white.withOpacity(0.05),
                      borderOpacity: achievement.isUnlocked ? 0.35 : 0.15,
                    ),
                    child: Row(
                      children: [
                        // Icon Badge
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: achievement.isUnlocked
                                ? GameTheme.accentGlow.withOpacity(0.2)
                                : Colors.white10,
                            border: Border.all(
                              color: achievement.isUnlocked
                                  ? GameTheme.accentGlow
                                  : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            achievement.isUnlocked
                                ? Icons.emoji_events_rounded
                                : Icons.lock_outline_rounded,
                            color: achievement.isUnlocked
                                ? GameTheme.coinGold
                                : Colors.white24,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title, details, progress
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    achievement.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: achievement.isUnlocked
                                          ? Colors.white
                                          : Colors.white60,
                                    ),
                                  ),
                                  // Coins reward badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: GameTheme.coinGold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: GameTheme.coinGold.withOpacity(0.3), width: 0.8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.stars, color: GameTheme.coinGold, size: 12),
                                        const SizedBox(width: 3),
                                        Text(
                                          '+${achievement.rewardCoins}',
                                          style: const TextStyle(
                                            color: GameTheme.coinGold,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievement.description,
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                              const SizedBox(height: 10),

                              // Progress bar
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (achievement.currentValue / achievement.targetValue)
                                            .clamp(0.0, 1.0),
                                        backgroundColor: Colors.white.withOpacity(0.08),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          achievement.isUnlocked
                                              ? GameTheme.accentGlow
                                              : Colors.white30,
                                        ),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${achievement.currentValue}/${achievement.targetValue}',
                                    style: TextStyle(
                                      color: achievement.isUnlocked
                                          ? Colors.white70
                                          : Colors.white38,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

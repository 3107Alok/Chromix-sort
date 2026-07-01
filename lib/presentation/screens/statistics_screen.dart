import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

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
                  'Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats Layout (Grid and List items)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Top Highlight Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.25,
                  children: [
                    _buildStatCard(
                      title: 'Levels Solved',
                      value: '${stats.totalLevelsCompleted}',
                      icon: Icons.checklist_rounded,
                      glowColor: Colors.greenAccent,
                    ),
                    _buildStatCard(
                      title: 'Best Streak',
                      value: '${stats.bestStreak} Days',
                      icon: Icons.local_fire_department_rounded,
                      glowColor: Colors.orangeAccent,
                    ),
                    _buildStatCard(
                      title: 'Total Moves',
                      value: '${stats.totalMoves}',
                      icon: Icons.compare_arrows_rounded,
                      glowColor: Colors.blueAccent,
                    ),
                    _buildStatCard(
                      title: 'Hints Used',
                      value: '${stats.totalHintsUsed}',
                      icon: Icons.lightbulb_rounded,
                      glowColor: Colors.yellowAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Large detailed stat bars
                _buildDetailsTile(
                  title: 'Total Play Time',
                  value: _formatPlayTime(stats.totalPlayTime),
                  icon: Icons.timer_rounded,
                ),
                const SizedBox(height: 16),

                _buildDetailsTile(
                  title: 'Average Moves / Level',
                  value: stats.averageMovesPerLevel.toStringAsFixed(1),
                  icon: Icons.calculate_rounded,
                ),
                const SizedBox(height: 16),
                
                _buildDetailsTile(
                  title: 'Current Streak',
                  value: '${stats.currentStreak} Days',
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color glowColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.glassDecoration(
        borderRadius: 20,
        color: glowColor.withOpacity(0.03),
      ).copyWith(
        border: Border.all(color: glowColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: glowColor, size: 22),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: glowColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: GameTheme.glassDecoration(borderRadius: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatPlayTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0m 0s';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }
}

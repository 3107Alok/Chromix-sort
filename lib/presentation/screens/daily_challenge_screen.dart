import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';
import 'game_screen.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final today = _getTodayDateString();
    final isCompleted = stats.completedDailies.contains(today);

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
                  'Daily Challenge',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Main Calendar Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: GameTheme.glassDecoration(borderRadius: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calendar graphic icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green.withOpacity(0.15)
                          : GameTheme.accentGlow.withOpacity(0.15),
                      border: Border.all(
                        color: isCompleted ? Colors.green : GameTheme.accentGlow,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.calendar_month_rounded,
                      color: isCompleted ? Colors.greenAccent : GameTheme.accentGlow,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Today's Date Display
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'COSMIC DAILY PUZZLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white30,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // Info details
                  Text(
                    isCompleted
                        ? 'Congratulations! You have completed today\'s cosmic daily challenge and earned the reward badge.'
                        : 'Every day, a unique procedurally-generated hard level is created. Complete it to earn +100 gold coins!',
                    style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Play / Completed Button
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () {
                            ref.read(audioProvider).playClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  levelNumber: 9999,
                                  isDaily: true,
                                  dailyDate: today,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.grey.withOpacity(0.12) : GameTheme.accentGlow,
                      foregroundColor: isCompleted ? Colors.white24 : Colors.white,
                      disabledBackgroundColor: Colors.white.withOpacity(0.04),
                      disabledForegroundColor: Colors.white24,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isCompleted ? 'CHALLENGE COMPLETED' : 'PLAY CHALLENGE',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),
          const Spacer(),
        ],
      ),
    );
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    final dayName = weekDays[now.weekday - 1];
    final monthName = months[now.month - 1];
    
    return "$dayName, $monthName ${now.day}, ${now.year}";
  }
}

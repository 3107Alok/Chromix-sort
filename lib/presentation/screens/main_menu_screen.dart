import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/stats_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'daily_challenge_screen.dart';
import 'achievements_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Initialize audio controller (starts background music)
    ref.read(audioProvider);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    return BackgroundWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Section (Coins Display)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: GameTheme.glassDecoration(borderRadius: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: GameTheme.coinGold, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${stats.coins}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Title
            Text(
              'BOTTLE SORT',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: GameTheme.accentGlow.withOpacity(0.8),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
            const Text(
              'Space Sort Challenge',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 60),

            // Pulsing Play Button
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.05);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GameTheme.accentGlow.withOpacity(0.3 + (_pulseController.value * 0.2)),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _navigateTo(context, GameScreen(levelNumber: stats.currentLevel)),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(40),
                        backgroundColor: GameTheme.accentGlow,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 45),
                          Text(
                            'PLAY',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            
            // Level Subtitle under Play button
            Text(
              'Level ${stats.currentLevel}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            
            const Spacer(),

            // Dashboard Grid Menu
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuButton(
                  context,
                  icon: Icons.grid_view_rounded,
                  label: 'Levels',
                  onTap: () => _navigateTo(context, const LevelSelectScreen()),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: 'Daily Challenge',
                  onTap: () => _navigateTo(context, const DailyChallengeScreen()),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.emoji_events_rounded,
                  label: 'Achievements',
                  onTap: () => _navigateTo(context, const AchievementsScreen()),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistics',
                  onTap: () => _navigateTo(context, const StatisticsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Settings Button
            _buildMenuButton(
              context,
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => _navigateTo(context, const SettingsScreen()),
              fullWidth: true,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(audioProvider).playClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: GameTheme.glassDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: 50, child: button);
    }
    return button;
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scale = Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

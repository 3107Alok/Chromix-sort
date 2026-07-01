import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/achievements_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

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
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Music Switch
                _buildSwitchTile(
                  title: 'Ambient Music',
                  subtitle: 'Continuous background space drone',
                  value: settings.musicOn,
                  onChanged: (val) {
                    ref.read(audioProvider).playClick();
                    settingsNotifier.toggleMusic();
                  },
                  icon: Icons.music_note_rounded,
                ),
                const SizedBox(height: 16),

                // Sound SFX Switch
                _buildSwitchTile(
                  title: 'Sound Effects (SFX)',
                  subtitle: 'Pour bubbles, clicks, and win trumpets',
                  value: settings.soundOn,
                  onChanged: (val) {
                    ref.read(audioProvider).playClick();
                    settingsNotifier.toggleSound();
                  },
                  icon: Icons.volume_up_rounded,
                ),
                const SizedBox(height: 16),

                // Haptic Feedback Switch
                _buildSwitchTile(
                  title: 'Haptic Feedback',
                  subtitle: 'Soft vibrations on select and pour',
                  value: settings.hapticOn,
                  onChanged: (val) {
                    ref.read(audioProvider).playClick();
                    settingsNotifier.toggleHaptic();
                  },
                  icon: Icons.vibration_rounded,
                ),
                const SizedBox(height: 16),

                // Language selection (Visual dropdown card)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: GameTheme.glassDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.language_rounded, color: Colors.white70, size: 22),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Game Language',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                'Select your preferred translation',
                                style: TextStyle(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: settings.language,
                        underline: const SizedBox(),
                        dropdownColor: GameTheme.bgStart,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            ref.read(audioProvider).playClick();
                            settingsNotifier.setLanguage(newValue);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'es', child: Text('Español')),
                          DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),

                // Reset Progress Button
                ElevatedButton(
                  onPressed: () => _confirmResetDialog(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever_rounded),
                      SizedBox(width: 8),
                      Text(
                        'RESET PROGRESS',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: GameTheme.glassDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 22),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: GameTheme.accentGlow,
            activeTrackColor: GameTheme.accentGlow.withOpacity(0.3),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  void _confirmResetDialog(BuildContext context, WidgetRef ref) {
    ref.read(audioProvider).playClick();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: GameTheme.bgStart,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white12, width: 1.5),
          ),
          title: const Text(
            'Reset Game Progress?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This action is irreversible. All completed levels, coins, daily challenge streaks, stats, and achievements will be erased.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(audioProvider).playClick();
                Navigator.pop(ctx);
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () async {
                ref.read(audioProvider).playClick();
                Navigator.pop(ctx);

                // Execute reset
                await ref.read(statsProvider.notifier).resetStats();
                await ref.read(achievementsProvider.notifier).resetAchievements();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Game progress successfully reset!'),
                    backgroundColor: Colors.red.shade900,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: const Text('RESET', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

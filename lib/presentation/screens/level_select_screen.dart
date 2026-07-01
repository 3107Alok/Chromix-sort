import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/models/game_state.dart';
import '../providers/stats_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';
import 'game_screen.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final completedLevels = stats.completedLevels.toSet();
    final currentUnlocked = stats.currentLevel;

    return BackgroundWidget(
      child: Column(
        children: [
          // Custom Header
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
                  'Select Level',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),

          // Difficulty Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: GameTheme.accentGlow,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Easy'),
              Tab(text: 'Medium'),
              Tab(text: 'Hard'),
              Tab(text: 'Expert'),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Views containing grid builders
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLevelGrid(1, 125, Difficulty.easy, completedLevels, currentUnlocked),
                _buildLevelGrid(126, 250, Difficulty.medium, completedLevels, currentUnlocked),
                _buildLevelGrid(251, 375, Difficulty.hard, completedLevels, currentUnlocked),
                _buildLevelGrid(376, 500, Difficulty.expert, completedLevels, currentUnlocked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(
    int startLevel,
    int endLevel,
    Difficulty difficulty,
    Set<int> completed,
    int currentUnlocked,
  ) {
    final totalCount = endLevel - startLevel + 1;

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final levelNum = startLevel + index;
        final isCompleted = completed.contains(levelNum);
        
        // Handcrafted levels 1 to 50 are unlocked sequentially.
        // Higher levels are unlocked if the previous level is completed.
        final isUnlocked = levelNum <= currentUnlocked || levelNum == 1;

        return _buildLevelCard(context, levelNum, difficulty, isCompleted, isUnlocked);
      },
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    int levelNum,
    Difficulty difficulty,
    bool isCompleted,
    bool isUnlocked,
  ) {
    BoxDecoration decoration;
    Widget child;

    if (isCompleted) {
      decoration = GameTheme.glassDecoration(borderRadius: 14, color: Colors.green.withOpacity(0.15));
      child = Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$levelNum',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Positioned(
            right: 4,
            bottom: 4,
            child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
          ),
        ],
      );
    } else if (isUnlocked) {
      decoration = GameTheme.glassDecoration(borderRadius: 14, borderOpacity: 0.25);
      child = Center(
        child: Text(
          '$levelNum',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    } else {
      decoration = GameTheme.glassDecoration(borderRadius: 14, color: Colors.black26, borderOpacity: 0.05);
      child = const Center(
        child: Icon(Icons.lock_rounded, color: Colors.white24, size: 20),
      );
    }

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              ref.read(audioProvider).playClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(levelNumber: levelNum, selectedDifficulty: difficulty),
                ),
              );
            }
          : null,
      child: Container(
        decoration: decoration,
        child: child,
      ),
    );
  }
}

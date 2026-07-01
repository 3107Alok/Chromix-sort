import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/move.dart';
import '../../domain/models/user_stats.dart';
import '../providers/game_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/background_widget.dart';
import '../widgets/game_board.dart';
import 'settings_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelNumber;
  final Difficulty selectedDifficulty;
  final bool isDaily;
  final String dailyDate;

  const GameScreen({
    super.key,
    required this.levelNumber,
    this.selectedDifficulty = Difficulty.easy,
    this.isDaily = false,
    this.dailyDate = '',
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late ConfettiController _confettiController;
  bool _isSolvingHint = false;
  Move? _latestHint;
  int _lastMovesCount = 0; // To reset hints if moves change
  bool _isWonDelayed = false; // Show victory only after pour animation completes

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Initialize game level state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isWonDelayed = false;
      });
      ref.read(gameProvider.notifier).initLevel(
            levelNumber: widget.levelNumber,
            difficulty: widget.selectedDifficulty,
            isDaily: widget.isDaily,
            dailyDate: widget.dailyDate,
          );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final stats = ref.watch(statsProvider);

    // If level is loading
    if (gameState == null) {
      return const BackgroundWidget(
        child: Center(
          child: CircularProgressIndicator(color: GameTheme.accentGlow),
        ),
      );
    }

    // Trigger confetti on victory once after animation finishes
    if (gameState.isWon && _isWonDelayed && _confettiController.state == ConfettiControllerState.stopped) {
      _triggerConfetti();
    }

    // Clear hint if move count changed
    if (gameState.moves != _lastMovesCount) {
      _latestHint = null;
      _lastMovesCount = gameState.moves;
    }

    return BackgroundWidget(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main layout Column
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. TOP HEADER SECTION
                _buildTopHeader(context, gameState, stats),
                
                const Spacer(),

                // Stuck indicator warning banner
                if (gameState.isStuck && !gameState.isWon) _buildStuckBanner(),

                // 2. CENTER STAGE (BOTTLES GRID)
                Expanded(
                  flex: 8,
                  child: Center(
                    child: GameBoard(
                      bottles: gameState.bottles,
                      selectedBottleId: gameState.selectedBottleId,
                      movesCount: gameState.moves,
                      onBottleTap: (id) {
                        ref.read(gameProvider.notifier).selectBottle(id);
                      },
                      onAnimationComplete: () {
                        if (gameState.isWon) {
                          setState(() {
                            _isWonDelayed = true;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // 3. BOTTOM CONTROL BUTTONS
                _buildBottomControls(gameState, stats),
                
                const SizedBox(height: 10),
              ],
            ),
          ),

          // 4. CONFETTI & VICTORY DIALOG
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow
            ],
          ),

          if (gameState.isWon && _isWonDelayed) _buildVictoryOverlay(gameState),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, GameState state, UserStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          onPressed: () {
            ref.read(audioProvider).playClick();
            Navigator.pop(context);
          },
        ),

        // Title and Difficulty
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              state.isDailyChallenge ? 'Daily Challenge' : 'Level ${state.levelNumber}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            if (!state.isDailyChallenge)
              Text(
                state.difficulty.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 2.0,
                ),
              ),
          ],
        ),

        // Right side: coins & settings
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: GameTheme.glassDecoration(borderRadius: 14),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: GameTheme.coinGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.coins}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
              onPressed: () {
                ref.read(audioProvider).playClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStuckBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: GameTheme.glassDecoration(
        borderRadius: 12,
        color: Colors.red.withOpacity(0.25),
        borderOpacity: 0.3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            'No moves left! Try Undo, Shuffle, or Bottle.',
            style: TextStyle(color: Colors.red.shade100, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(GameState state, UserStats stats) {
    // Check if undo has history
    final hasUndo = state.undoStack.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.glassDecoration(borderRadius: 24),
      child: Column(
        children: [
          // Row 1: Primary actions (Hint, Undo, Extra Bottle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Hint Button
              _buildActionButton(
                icon: _isSolvingHint ? Icons.hourglass_empty_rounded : Icons.lightbulb_outline_rounded,
                label: 'Hint (100)',
                onPressed: _isSolvingHint
                    ? null
                    : () async {
                        if (stats.coins < 100) {
                          _showCoinWarning();
                          return;
                        }
                        setState(() => _isSolvingHint = true);
                        final hint = await ref.read(gameProvider.notifier).requestHint();
                        setState(() {
                          _isSolvingHint = false;
                          _latestHint = hint;
                        });
                        
                        if (hint == null) {
                          _showToast('No solvable path found! Use Shuffle or Bottle.');
                        } else {
                          _showToast('Tip: Pour bottle ${hint.fromBottleId + 1} to bottle ${hint.toBottleId + 1}!');
                        }
                      },
                glowColor: Colors.yellowAccent,
              ),

              // Undo Button
              _buildActionButton(
                icon: Icons.undo_rounded,
                label: 'Undo',
                onPressed: hasUndo
                    ? () {
                        ref.read(gameProvider.notifier).undo();
                      }
                    : null,
                opacity: hasUndo ? 1.0 : 0.4,
              ),

              // Restart Button
              _buildActionButton(
                icon: Icons.refresh_rounded,
                label: 'Restart',
                onPressed: () {
                  ref.read(gameProvider.notifier).restart();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Helper Shop actions (Shuffle, Extra Bottle, Skip)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Shuffle Button (50 coins)
              _buildActionButton(
                icon: Icons.shuffle_rounded,
                label: 'Shuffle (50)',
                onPressed: () async {
                  if (stats.coins < 50) {
                    _showCoinWarning();
                    return;
                  }
                  final success = await ref.read(gameProvider.notifier).shuffle();
                  if (!success) {
                    _showToast('Nothing to shuffle!');
                  }
                },
                glowColor: Colors.orangeAccent,
              ),

              // Extra Bottle (150 coins)
              _buildActionButton(
                icon: Icons.add_box_outlined,
                label: 'Bottle (150)',
                onPressed: () async {
                  if (stats.coins < 150) {
                    _showCoinWarning();
                    return;
                  }
                  final success = await ref.read(gameProvider.notifier).addExtraBottle();
                  if (!success) {
                    _showToast('Limit reached for this level.');
                  }
                },
                glowColor: Colors.cyanAccent,
              ),

              // Skip Level (200 coins)
              _buildActionButton(
                icon: Icons.skip_next_rounded,
                label: 'Skip (200)',
                onPressed: () async {
                  if (stats.coins < 200) {
                    _showCoinWarning();
                    return;
                  }
                  await ref.read(gameProvider.notifier).skipLevel();
                },
                glowColor: Colors.purpleAccent,
              ),
            ],
          ),
          
          // Visual Hint representation overlay
          if (_latestHint != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow.withOpacity(0.3)),
              ),
              child: Text(
                'HINT: Pour Bottle ${_latestHint!.fromBottleId + 1} ➔ Bottle ${_latestHint!.toBottleId + 1}',
                style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    double opacity = 1.0,
    Color? glowColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed != null ? () {
          ref.read(audioProvider).playClick();
          onPressed();
        } : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 85,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: glowColor?.withOpacity(0.3) ?? Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: glowColor != null
                  ? [
                      BoxShadow(
                        color: glowColor.withOpacity(0.08),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: glowColor ?? Colors.white70, size: 20),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: glowColor ?? Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay(GameState state) {
    // Simple star logic: less than 15 moves = 3 stars, less than 25 = 2 stars, otherwise 1
    int stars = 1;
    if (state.moves <= 15) {
      stars = 3;
    } else if (state.moves <= 25) {
      stars = 2;
    }

    return Container(
      color: Colors.black.withOpacity(0.75),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.elasticOut,
        builder: (context, val, child) {
          return Transform.scale(
            scale: val,
            child: child,
          );
        },
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: GameTheme.glassDecoration(
            borderRadius: 28,
            color: GameTheme.bgStart.withOpacity(0.85),
            borderOpacity: 0.3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'VICTORY!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.greenAccent,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(color: Colors.green.withOpacity(0.6), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Star Rankings
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < stars ? GameTheme.coinGold : Colors.white24,
                    size: 38,
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Stats summary
              Text(
                'Completed in ${state.moves} moves',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 10),
              
              // Reward Coins
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: GameTheme.coinGold, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '+20 Coins Reward',
                    style: TextStyle(color: Colors.amber.shade200, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(audioProvider).playClick();
                      if (state.isDailyChallenge) {
                        Navigator.pop(context);
                      } else {
                        // Go to next level
                        ref.read(gameProvider.notifier).initLevel(
                              levelNumber: state.levelNumber + 1,
                              difficulty: widget.selectedDifficulty,
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.accentGlow,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      state.isDailyChallenge ? 'BACK TO MAIN' : 'NEXT LEVEL',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      ref.read(audioProvider).playClick();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('BACK TO MENU'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoinWarning() {
    _showToast('Not enough coins!');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: GameTheme.bgStart.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

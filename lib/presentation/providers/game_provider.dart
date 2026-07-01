import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engine/handcrafted_levels.dart';
import '../../domain/engine/level_generator.dart';
import '../../domain/engine/move_validator.dart';
import '../../domain/engine/hint_solver.dart';
import '../../domain/models/bottle.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/move.dart';
import 'storage_provider.dart';
import 'stats_provider.dart';
import 'achievements_provider.dart';
import 'audio_provider.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState?>(
  GameNotifier.new,
);

class GameNotifier extends Notifier<GameState?> {
  @override
  GameState? build() => null; // Null until initLevel() is called

  /// Initializes the level. Restores auto-saved progress if it matches the level.
  Future<void> initLevel({
    required int levelNumber,
    required Difficulty difficulty,
    bool isDaily = false,
    String dailyDate = '',
  }) async {
    final storage = ref.read(storageProvider);
    final savedState = storage.loadGameState();

    // Restore auto-saved state if it matches this level
    if (savedState != null &&
        savedState.levelNumber == levelNumber &&
        savedState.isDailyChallenge == isDaily &&
        (!isDaily || savedState.dailyDate == dailyDate)) {
      state = savedState;
      return;
    }

    List<Bottle> bottles;
    if (isDaily) {
      bottles = LevelGenerator.generateDailyChallenge(dailyDate);
    } else {
      final handcrafted = HandcraftedLevels.getLevel(levelNumber);
      if (handcrafted != null) {
        bottles = handcrafted;
        difficulty = HandcraftedLevels.getDifficulty(levelNumber);
      } else {
        bottles = LevelGenerator.generateLevel(
          levelNumber: levelNumber,
          difficulty: difficulty,
        );
      }
    }

    final newState = GameState(
      bottles: bottles,
      moves: 0,
      undoStack: const [],
      selectedBottleId: null,
      isWon: false,
      isStuck: !MoveValidator.hasAnyValidMoves(bottles),
      levelNumber: levelNumber,
      difficulty: difficulty,
      isDailyChallenge: isDaily,
      dailyDate: dailyDate,
    );

    state = newState;
    await storage.saveGameState(newState);
  }

  /// Taps a bottle. Returns true if a pour occurred.
  bool selectBottle(int bottleId) {
    if (state == null || state!.isWon) return false;

    final bottles = state!.bottles;
    final selectedId = state!.selectedBottleId;
    final targetIndex = bottles.indexWhere((b) => b.id == bottleId);
    if (targetIndex == -1) return false;

    final targetBottle = bottles[targetIndex];

    // No bottle selected — select this one
    if (selectedId == null) {
      if (targetBottle.isEmpty) return false;
      state = state!.copyWith(selectedBottleId: bottleId);
      ref.read(audioProvider).playClick();
      return false;
    }

    // Tap same bottle — deselect
    if (selectedId == bottleId) {
      state = state!.copyWith(selectedBottleId: null);
      ref.read(audioProvider).playClick();
      return false;
    }

    // Attempt pour from selected to tapped
    final sourceIndex = bottles.indexWhere((b) => b.id == selectedId);
    if (sourceIndex == -1) return false;
    final sourceBottle = bottles[sourceIndex];

    if (MoveValidator.isValidMove(sourceBottle, targetBottle)) {
      final updatedUndoStack =
          List<List<Bottle>>.from(state!.undoStack)..add(bottles);
      final nextBottles =
          MoveValidator.performMove(bottles, selectedId, bottleId);

      if (nextBottles != null) {
        final won = MoveValidator.checkWin(nextBottles);
        final stuck = !won && !MoveValidator.hasAnyValidMoves(nextBottles);
        final nextMoves = state!.moves + 1;

        final updatedState = state!.copyWith(
          bottles: nextBottles,
          moves: nextMoves,
          undoStack: updatedUndoStack,
          selectedBottleId: null,
          isWon: won,
          isStuck: stuck,
        );

        state = updatedState;
        ref.read(audioProvider).playPour();

        if (won) {
          _handleWin(nextMoves);
        } else {
          ref.read(storageProvider).saveGameState(updatedState);
        }
        return true;
      }
    }

    // Pour invalid — re-select target if non-empty
    if (!targetBottle.isEmpty) {
      state = state!.copyWith(selectedBottleId: bottleId);
    } else {
      state = state!.copyWith(selectedBottleId: null);
    }
    ref.read(audioProvider).playClick();
    return false;
  }

  void _handleWin(int finalMoves) async {
    await ref.read(storageProvider).clearGameState();
    ref.read(audioProvider).playWin();

    final statsNotifier = ref.read(statsProvider.notifier);
    if (state!.isDailyChallenge) {
      await statsNotifier.dailyChallengeCompleted(state!.dailyDate);
    } else {
      await statsNotifier.levelCompleted(state!.levelNumber, finalMoves);
    }

    final stats = ref.read(statsProvider);
    final achievementsNotifier = ref.read(achievementsProvider.notifier);
    await achievementsNotifier.evaluateStats(stats);

    if (finalMoves < 12) {
      await achievementsNotifier.triggerAchievementAction('efficiency');
    }
    if (state!.isDailyChallenge) {
      await achievementsNotifier.triggerAchievementAction('daily_challenge');
    }
  }

  /// Undo the last move.
  void undo() {
    if (state == null || state!.isWon || state!.undoStack.isEmpty) return;

    final updatedUndoStack = List<List<Bottle>>.from(state!.undoStack);
    final previousBottles = updatedUndoStack.removeLast();

    final updatedState = state!.copyWith(
      bottles: previousBottles,
      moves: max(0, state!.moves - 1),
      undoStack: updatedUndoStack,
      selectedBottleId: null,
      isWon: false,
      isStuck: !MoveValidator.hasAnyValidMoves(previousBottles),
    );

    state = updatedState;
    ref.read(audioProvider).playClick();
    ref.read(storageProvider).saveGameState(updatedState);
  }

  /// Restart current level.
  void restart() {
    if (state == null) return;
    ref.read(audioProvider).playClick();
    initLevel(
      levelNumber: state!.levelNumber,
      difficulty: state!.difficulty,
      isDaily: state!.isDailyChallenge,
      dailyDate: state!.dailyDate,
    );
  }

  /// Skip current level (costs 200 coins).
  Future<bool> skipLevel() async {
    if (state == null || state!.isWon) return false;

    final success = await ref.read(statsProvider.notifier).spendCoins(200);
    if (!success) return false;

    _handleWin(state!.moves);
    state = state!.copyWith(isWon: true);
    return true;
  }

  /// Add an extra empty bottle (costs 150 coins).
  Future<bool> addExtraBottle() async {
    if (state == null || state!.isWon) return false;

    // Compute original bottle count from difficulty config
    final params = LevelGenerator.difficultyParams[state!.difficulty];
    final originalCount = state!.isDailyChallenge
        ? 9
        : (HandcraftedLevels.getLevel(state!.levelNumber)?.length ??
            ((params?.colors ?? 5) + (params?.empty ?? 2)));

    if (state!.bottles.length > originalCount) return false;

    final success = await ref.read(statsProvider.notifier).spendCoins(150);
    if (!success) return false;

    final nextBottles = List<Bottle>.from(state!.bottles);
    final newId = nextBottles.map((b) => b.id).reduce(max) + 1;
    nextBottles.add(Bottle(id: newId, layers: const []));

    final updatedState = state!.copyWith(
      bottles: nextBottles,
      isStuck: !MoveValidator.hasAnyValidMoves(nextBottles),
      selectedBottleId: null,
    );

    state = updatedState;
    ref.read(audioProvider).playClick();
    await ref.read(storageProvider).saveGameState(updatedState);
    return true;
  }

  /// Shuffle non-complete bottles (costs 50 coins).
  Future<bool> shuffle() async {
    if (state == null || state!.isWon) return false;

    final success = await ref.read(statsProvider.notifier).spendCoins(50);
    if (!success) return false;

    final bottles = state!.bottles;
    final shuffleIndices = <int>[];
    final colorPool = <int>[];

    for (int i = 0; i < bottles.length; i++) {
      if (!bottles[i].isComplete && !bottles[i].isEmpty) {
        shuffleIndices.add(i);
        colorPool.addAll(bottles[i].layers);
      }
    }

    if (colorPool.isEmpty || shuffleIndices.length < 2) return true;

    final random = Random();
    List<Bottle> nextBottles = List.from(bottles);

    for (int attempt = 0; attempt < 50; attempt++) {
      colorPool.shuffle(random);
      nextBottles = List.from(bottles);
      int offset = 0;

      for (final idx in shuffleIndices) {
        final size = bottles[idx].layers.length;
        final newLayers = <int>[];
        for (int j = 0; j < size; j++) {
          newLayers.add(colorPool[offset++]);
        }
        nextBottles[idx] = bottles[idx].copyWith(layers: newLayers);
      }

      if (!MoveValidator.checkWin(nextBottles) &&
          HintSolver.solve(nextBottles) != null) {
        break;
      }
    }

    final updatedUndoStack =
        List<List<Bottle>>.from(state!.undoStack)..add(bottles);
    final updatedState = state!.copyWith(
      bottles: nextBottles,
      undoStack: updatedUndoStack,
      selectedBottleId: null,
      isStuck: !MoveValidator.hasAnyValidMoves(nextBottles),
    );

    state = updatedState;
    ref.read(audioProvider).playClick();
    await ref.read(storageProvider).saveGameState(updatedState);
    return true;
  }

  /// Request a hint (costs 100 coins). Runs solver on background isolate.
  Future<Move?> requestHint() async {
    if (state == null || state!.isWon) return null;

    final success = await ref.read(statsProvider.notifier).spendCoins(100);
    if (!success) return null;

    await ref.read(statsProvider.notifier).incrementHintsUsed();
    final stats = ref.read(statsProvider);
    await ref.read(achievementsProvider.notifier).evaluateStats(stats);

    // Runs on background isolate via compute()
    return await HintSolver.findHint(state!.bottles);
  }
}

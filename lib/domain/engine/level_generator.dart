import 'dart:math';
import '../models/bottle.dart';
import '../models/game_state.dart';
import 'hint_solver.dart';
import 'move_validator.dart';

class LevelGenerator {
  /// Maps difficulty to the number of colors (filled bottles) and empty bottles.
  static Map<Difficulty, LevelParams> get difficultyParams => {
        Difficulty.easy: const LevelParams(colors: 3, empty: 2),
        Difficulty.medium: const LevelParams(colors: 5, empty: 2),
        Difficulty.hard: const LevelParams(colors: 7, empty: 2),
        Difficulty.expert: const LevelParams(colors: 9, empty: 2),
      };

  /// Generates a solvable level based on the level number.
  /// First 50 levels are handcrafted, higher levels are procedural.
  static List<Bottle> generateLevel({
    required int levelNumber,
    required Difficulty difficulty,
    int? deterministicSeed,
  }) {
    final random = deterministicSeed != null ? Random(deterministicSeed) : Random();

    // Determine the parameters based on difficulty
    final params = difficultyParams[difficulty]!;

    // Perform procedural generation
    for (int attempt = 0; attempt < 100; attempt++) {
      final bottles = _generateRandomBoard(params.colors, params.empty, random);
      // Validate that the board is solvable and not already solved
      if (!MoveValidator.checkWin(bottles) && HintSolver.solve(bottles) != null) {
        return bottles;
      }
    }

    // Fallback solvable board if generation fails 100 times
    return _getFallbackBoard(params.colors, params.empty);
  }

  /// Generates the deterministic daily challenge level using the YYYY-MM-DD date string as seed.
  static List<Bottle> generateDailyChallenge(String dateString) {
    final seed = _getSeedFromDate(dateString);
    // Daily challenges are always "Hard" difficulty
    return generateLevel(levelNumber: 9999, difficulty: Difficulty.hard, deterministicSeed: seed);
  }

  /// Helper to convert a date string (YYYY-MM-DD) into a numerical seed.
  static int _getSeedFromDate(String dateStr) {
    int hash = 0;
    for (int i = 0; i < dateStr.length; i++) {
      hash = dateStr.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs();
  }

  /// Generates a random board configuration.
  static List<Bottle> _generateRandomBoard(int numColors, int numEmpty, Random random) {
    // 1. Create a pool of colors (4 layers per color)
    final colorPool = <int>[];
    for (int c = 1; c <= numColors; c++) {
      for (int i = 0; i < 4; i++) {
        colorPool.add(c);
      }
    }

    // 2. Shuffle color pool
    colorPool.shuffle(random);

    // 3. Distribute colors into bottles
    final bottles = <Bottle>[];
    int bottleId = 0;
    
    for (int b = 0; b < numColors; b++) {
      final layers = <int>[];
      for (int i = 0; i < 4; i++) {
        layers.add(colorPool[b * 4 + i]);
      }
      bottles.add(Bottle(id: bottleId++, layers: layers));
    }

    // 4. Add empty bottles
    for (int e = 0; e < numEmpty; e++) {
      bottles.add(Bottle(id: bottleId++, layers: const []));
    }

    return bottles;
  }

  /// Generates a simple, guaranteed-solvable fallback board.
  static List<Bottle> _getFallbackBoard(int numColors, int numEmpty) {
    final bottles = <Bottle>[];
    int bottleId = 0;

    // Distribute sorted colors but swap the top elements of adjacent bottles to make it a simple puzzle
    for (int c = 1; c <= numColors; c++) {
      final layers = List<int>.filled(4, c);
      bottles.add(Bottle(id: bottleId++, layers: layers));
    }

    // Swap top layers of adjacent bottles
    for (int i = 0; i < numColors - 1; i += 2) {
      final b1Layers = List<int>.from(bottles[i].layers);
      final b2Layers = List<int>.from(bottles[i + 1].layers);
      
      final temp = b1Layers.last;
      b1Layers[3] = b2Layers.last;
      b2Layers[3] = temp;
      
      bottles[i] = bottles[i].copyWith(layers: b1Layers);
      bottles[i + 1] = bottles[i + 1].copyWith(layers: b2Layers);
    }

    // Add empty bottles
    for (int e = 0; e < numEmpty; e++) {
      bottles.add(Bottle(id: bottleId++, layers: const []));
    }

    return bottles;
  }
}

class LevelParams {
  final int colors;
  final int empty;

  const LevelParams({
    required this.colors,
    required this.empty,
  });
}

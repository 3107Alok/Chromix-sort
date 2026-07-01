import 'package:flutter_test/flutter_test.dart';
import 'package:bottlesort/domain/models/bottle.dart';
import 'package:bottlesort/domain/engine/move_validator.dart';
import 'package:bottlesort/domain/engine/level_generator.dart';
import 'package:bottlesort/domain/engine/hint_solver.dart';
import 'package:bottlesort/domain/models/game_state.dart';

void main() {
  group('Bottle Model Tests', () {
    test('Empty bottle properties', () {
      const bottle = Bottle(id: 0, layers: []);
      expect(bottle.isEmpty, true);
      expect(bottle.isFull, false);
      expect(bottle.topColor, -1);
      expect(bottle.topColorCount, 0);
      expect(bottle.spaceAvailable, 4);
    });

    test('Full homogeneous bottle completion', () {
      const bottle = Bottle(id: 1, layers: [2, 2, 2, 2]);
      expect(bottle.isEmpty, false);
      expect(bottle.isFull, true);
      expect(bottle.isComplete, true);
      expect(bottle.topColor, 2);
      expect(bottle.topColorCount, 4);
    });

    test('Incomplete homogeneous bottle properties', () {
      const bottle = Bottle(id: 2, layers: [3, 3]);
      expect(bottle.isComplete, false);
      expect(bottle.isSingleColor, true);
      expect(bottle.topColorCount, 2);
    });
  });

  group('Move Validator Tests', () {
    test('Pouring into empty bottle is valid', () {
      const b1 = Bottle(id: 0, layers: [1, 2]);
      const b2 = Bottle(id: 1, layers: []);
      expect(MoveValidator.isValidMove(b1, b2), true);
      expect(MoveValidator.getPourAmount(b1, b2), 1); // pour the 2
    });

    test('Pouring matching top color is valid', () {
      const b1 = Bottle(id: 0, layers: [1, 2]);
      const b2 = Bottle(id: 1, layers: [3, 2]);
      expect(MoveValidator.isValidMove(b1, b2), true);
    });

    test('Pouring mismatching top color is invalid', () {
      const b1 = Bottle(id: 0, layers: [1, 2]);
      const b2 = Bottle(id: 1, layers: [3, 4]);
      expect(MoveValidator.isValidMove(b1, b2), false);
    });

    test('Win detection', () {
      final bottles = [
        const Bottle(id: 0, layers: [1, 1, 1, 1]),
        const Bottle(id: 1, layers: [2, 2, 2, 2]),
        const Bottle(id: 2, layers: []),
      ];
      expect(MoveValidator.checkWin(bottles), true);
    });
  });

  group('Level Generator & Solver Tests', () {
    test('Daily challenge generation and solving', () {
      final bottles = LevelGenerator.generateDailyChallenge('2026-06-30');
      expect(bottles.length, 9); // Hard difficulty parameters = 7 colors + 2 empty

      // Verify that a hint can be generated (level is solvable)
      final hint = HintSolver.solve(bottles);
      expect(hint, isNotNull);
    });
  });
}

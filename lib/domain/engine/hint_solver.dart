import 'package:flutter/foundation.dart';
import '../models/bottle.dart';
import '../models/move.dart';
import 'move_validator.dart';

class SolverInput {
  final List<Bottle> bottles;
  SolverInput(this.bottles);
}

class HintSolver {
  /// Generates a canonical state key that ignores bottle IDs and order to collapse isomorphic states.
  static String getStateKey(List<Bottle> bottles) {
    final list = bottles.map((b) => b.layers.join(',')).toList();
    list.sort();
    return list.join(';');
  }

  /// Entry point for hint solving. Runs the solver on a background Isolate.
  static Future<Move?> findHint(List<Bottle> bottles) async {
    // Run on isolate to avoid blocking the main UI thread
    return await compute(_solveIsolate, SolverInput(bottles));
  }

  /// Worker function executed in the isolate.
  static Move? _solveIsolate(SolverInput input) {
    return solve(input.bottles);
  }

  /// Solves the board and returns the first move of the solution path.
  /// Uses BFS for smaller boards and A* for larger boards.
  static Move? solve(List<Bottle> bottles) {
    if (MoveValidator.checkWin(bottles)) return null;

    if (bottles.length <= 7) {
      return _solveBFS(bottles);
    } else {
      return _solveAStar(bottles);
    }
  }

  /// BFS Solver for smaller boards.
  static Move? _solveBFS(List<Bottle> initialBottles) {
    final queue = <_SolverNode>[];
    final visited = <String>{};

    final root = _SolverNode(bottles: initialBottles, path: []);
    queue.add(root);
    visited.add(getStateKey(initialBottles));

    // Limit maximum states to prevent memory issues or infinite search
    int statesExplored = 0;
    const maxStates = 5000;

    while (queue.isNotEmpty && statesExplored < maxStates) {
      final node = queue.removeAt(0);
      statesExplored++;

      if (MoveValidator.checkWin(node.bottles)) {
        if (node.path.isNotEmpty) {
          return node.path.first;
        }
        return null;
      }

      // Generate next states
      for (int i = 0; i < node.bottles.length; i++) {
        for (int j = 0; j < node.bottles.length; j++) {
          if (i == j) continue;
          final from = node.bottles[i];
          final to = node.bottles[j];

          if (MoveValidator.isValidMove(from, to)) {
            final nextBottles = MoveValidator.performMove(node.bottles, from.id, to.id);
            if (nextBottles != null) {
              final key = getStateKey(nextBottles);
              if (!visited.contains(key)) {
                visited.add(key);
                final move = Move(
                  fromBottleId: from.id,
                  toBottleId: to.id,
                  color: from.topColor,
                  count: MoveValidator.getPourAmount(from, to),
                );
                queue.add(_SolverNode(
                  bottles: nextBottles,
                  path: [...node.path, move],
                ));
              }
            }
          }
        }
      }
    }

    return null; // Unsolvable or limit reached
  }

  /// A* Solver for larger boards.
  static Move? _solveAStar(List<Bottle> initialBottles) {
    // We use a simple priority queue implementation in Dart
    final openSet = <_AStarNode>[];
    final visited = <String, int>{}; // Key -> g-score

    final root = _AStarNode(
      bottles: initialBottles,
      path: [],
      g: 0,
      h: _calculateHeuristic(initialBottles),
    );
    openSet.add(root);
    visited[getStateKey(initialBottles)] = 0;

    int statesExplored = 0;
    const maxStates = 8000;

    while (openSet.isNotEmpty && statesExplored < maxStates) {
      // Sort openSet by f = g + h (smallest first)
      openSet.sort((a, b) => a.f.compareTo(b.f));
      final node = openSet.removeAt(0);
      statesExplored++;

      if (MoveValidator.checkWin(node.bottles)) {
        if (node.path.isNotEmpty) {
          return node.path.first;
        }
        return null;
      }

      for (int i = 0; i < node.bottles.length; i++) {
        for (int j = 0; j < node.bottles.length; j++) {
          if (i == j) continue;
          final from = node.bottles[i];
          final to = node.bottles[j];

          if (MoveValidator.isValidMove(from, to)) {
            final nextBottles = MoveValidator.performMove(node.bottles, from.id, to.id);
            if (nextBottles != null) {
              final key = getStateKey(nextBottles);
              final newG = node.g + 1;

              if (!visited.containsKey(key) || newG < visited[key]!) {
                visited[key] = newG;
                final move = Move(
                  fromBottleId: from.id,
                  toBottleId: to.id,
                  color: from.topColor,
                  count: MoveValidator.getPourAmount(from, to),
                );
                final nextNode = _AStarNode(
                  bottles: nextBottles,
                  path: [...node.path, move],
                  g: newG,
                  h: _calculateHeuristic(nextBottles),
                );
                openSet.add(nextNode);
              }
            }
          }
        }
      }
    }

    return null; // Unsolvable or limit reached
  }

  /// Calculates A* heuristic score.
  /// Lower is closer to solved state.
  static int _calculateHeuristic(List<Bottle> bottles) {
    int h = 0;
    for (final bottle in bottles) {
      if (bottle.isEmpty) continue;

      // Count unique colors in this bottle
      final uniqueColors = bottle.layers.toSet();
      
      if (uniqueColors.length > 1) {
        // High penalty for mixed bottles
        h += uniqueColors.length * 4;
        
        // Add penalty for colors on top of other colors
        for (int i = 1; i < bottle.layers.length; i++) {
          if (bottle.layers[i] != bottle.layers[i - 1]) {
            h += (bottle.layers.length - i) * 2;
          }
        }
      } else {
        // Only 1 color, but is it complete?
        if (bottle.layers.length < bottle.capacity) {
          // It's incomplete, penalty is proportional to missing space
          h += (bottle.capacity - bottle.layers.length);
        }
      }
    }
    return h;
  }
}

class _SolverNode {
  final List<Bottle> bottles;
  final List<Move> path;

  _SolverNode({
    required this.bottles,
    required this.path,
  });
}

class _AStarNode {
  final List<Bottle> bottles;
  final List<Move> path;
  final int g; // Cost to reach this node
  final int h; // Heuristic cost to goal

  _AStarNode({
    required this.bottles,
    required this.path,
    required this.g,
    required this.h,
  });

  int get f => g + h;
}

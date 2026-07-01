import '../models/bottle.dart';

class MoveValidator {
  /// Checks if a move from [from] bottle to [to] bottle is valid.
  static bool isValidMove(Bottle from, Bottle to) {
    if (from.id == to.id) return false;
    if (from.isEmpty) return false;
    if (to.isFull) return false;

    // A completed bottle (all layers same color and full) should not be poured from,
    // though in some versions you can, preventing it makes hint/solvers more efficient
    // and guides the user. Let's allow it but we can optimize solver by ignoring it.
    if (from.isComplete) return false;

    if (to.isEmpty) return true;

    return from.topColor == to.topColor;
  }

  /// Calculates how many layers of liquid will be poured.
  static int getPourAmount(Bottle from, Bottle to) {
    if (!isValidMove(from, to)) return 0;
    
    final color = from.topColor;
    final count = from.topColorCount;
    final available = to.spaceAvailable;
    
    return count < available ? count : available;
  }

  /// Applies the pouring move from [fromId] to [toId] on the [bottles] list.
  /// Returns a new list of bottles representing the updated state.
  static List<Bottle>? performMove(List<Bottle> bottles, int fromId, int toId) {
    final fromIndex = bottles.indexWhere((b) => b.id == fromId);
    final toIndex = bottles.indexWhere((b) => b.id == toId);
    
    if (fromIndex == -1 || toIndex == -1) return null;
    
    final from = bottles[fromIndex];
    final to = bottles[toIndex];
    
    if (!isValidMove(from, to)) return null;
    
    final amount = getPourAmount(from, to);
    if (amount == 0) return null;
    
    final color = from.topColor;
    
    // Modify from bottle
    final newFromLayers = List<int>.from(from.layers);
    for (int i = 0; i < amount; i++) {
      if (newFromLayers.isNotEmpty) {
        newFromLayers.removeLast();
      }
    }
    final newFrom = from.copyWith(layers: newFromLayers);
    
    // Modify to bottle
    final newToLayers = List<int>.from(to.layers);
    for (int i = 0; i < amount; i++) {
      newToLayers.add(color);
    }
    final newTo = to.copyWith(layers: newToLayers);
    
    // Create new bottles list
    final newBottles = List<Bottle>.from(bottles);
    newBottles[fromIndex] = newFrom;
    newBottles[toIndex] = newTo;
    
    return newBottles;
  }

  /// Checks if any valid move exists on the board.
  static bool hasAnyValidMoves(List<Bottle> bottles) {
    for (int i = 0; i < bottles.length; i++) {
      for (int j = 0; j < bottles.length; j++) {
        if (i == j) continue;
        if (isValidMove(bottles[i], bottles[j])) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks if the board is in a winning state.
  /// Every bottle must be complete (all same color and full) OR completely empty.
  static bool checkWin(List<Bottle> bottles) {
    for (final bottle in bottles) {
      if (bottle.isEmpty) continue;
      if (!bottle.isComplete) return false;
    }
    return true;
  }
}

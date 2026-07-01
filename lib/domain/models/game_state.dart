import 'bottle.dart';

enum Difficulty { easy, medium, hard, expert }

class GameState {
  final List<Bottle> bottles;
  final int moves;
  final List<List<Bottle>> undoStack;
  final int? selectedBottleId;
  final bool isWon;
  final bool isStuck; // No valid moves possible
  final int levelNumber;
  final Difficulty difficulty;
  final bool isDailyChallenge;
  final String dailyDate; // YYYY-MM-DD for daily challenge

  const GameState({
    required this.bottles,
    this.moves = 0,
    this.undoStack = const [],
    this.selectedBottleId,
    this.isWon = false,
    this.isStuck = false,
    required this.levelNumber,
    required this.difficulty,
    this.isDailyChallenge = false,
    this.dailyDate = '',
  });

  GameState copyWith({
    List<Bottle>? bottles,
    int? moves,
    List<List<Bottle>>? undoStack,
    int? selectedBottleId,
    bool? isWon,
    bool? isStuck,
    int? levelNumber,
    Difficulty? difficulty,
    bool? isDailyChallenge,
    String? dailyDate,
  }) {
    return GameState(
      bottles: bottles ?? this.bottles,
      moves: moves ?? this.moves,
      undoStack: undoStack ?? this.undoStack,
      selectedBottleId: selectedBottleId, // note: allows passing null
      isWon: isWon ?? this.isWon,
      isStuck: isStuck ?? this.isStuck,
      levelNumber: levelNumber ?? this.levelNumber,
      difficulty: difficulty ?? this.difficulty,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      dailyDate: dailyDate ?? this.dailyDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bottles': bottles.map((b) => b.toJson()).toList(),
      'moves': moves,
      'undoStack': undoStack.map((stack) => stack.map((b) => b.toJson()).toList()).toList(),
      'selectedBottleId': selectedBottleId,
      'isWon': isWon,
      'isStuck': isStuck,
      'levelNumber': levelNumber,
      'difficulty': difficulty.index,
      'isDailyChallenge': isDailyChallenge,
      'dailyDate': dailyDate,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      bottles: (json['bottles'] as List).map((b) => Bottle.fromJson(b as Map<String, dynamic>)).toList(),
      moves: json['moves'] as int? ?? 0,
      undoStack: (json['undoStack'] as List? ?? const [])
          .map((stack) => (stack as List).map((b) => Bottle.fromJson(b as Map<String, dynamic>)).toList())
          .toList(),
      selectedBottleId: json['selectedBottleId'] as int?,
      isWon: json['isWon'] as bool? ?? false,
      isStuck: json['isStuck'] as bool? ?? false,
      levelNumber: json['levelNumber'] as int? ?? 1,
      difficulty: Difficulty.values[json['difficulty'] as int? ?? 0],
      isDailyChallenge: json['isDailyChallenge'] as bool? ?? false,
      dailyDate: json['dailyDate'] as String? ?? '',
    );
  }
}

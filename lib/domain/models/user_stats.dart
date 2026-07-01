class UserStats {
  final int currentLevel;
  final int coins;
  final List<int> completedLevels;
  final List<String> completedDailies; // YYYY-MM-DD strings of completed challenges
  final int totalMoves;
  final int bestStreak;
  final int currentStreak;
  final int totalPlayTime; // in seconds
  final int totalHintsUsed;
  final String lastPlayedDate; // YYYY-MM-DD for streaks

  const UserStats({
    this.currentLevel = 1,
    this.coins = 200, // starting balance
    this.completedLevels = const [],
    this.completedDailies = const [],
    this.totalMoves = 0,
    this.bestStreak = 0,
    this.currentStreak = 0,
    this.totalPlayTime = 0,
    this.totalHintsUsed = 0,
    this.lastPlayedDate = '',
  });

  int get totalLevelsCompleted => completedLevels.length;

  double get averageMovesPerLevel {
    if (completedLevels.isEmpty) return 0.0;
    return totalMoves / completedLevels.length;
  }

  UserStats copyWith({
    int? currentLevel,
    int? coins,
    List<int>? completedLevels,
    List<String>? completedDailies,
    int? totalMoves,
    int? bestStreak,
    int? currentStreak,
    int? totalPlayTime,
    int? totalHintsUsed,
    String? lastPlayedDate,
  }) {
    return UserStats(
      currentLevel: currentLevel ?? this.currentLevel,
      coins: coins ?? this.coins,
      completedLevels: completedLevels ?? this.completedLevels,
      completedDailies: completedDailies ?? this.completedDailies,
      totalMoves: totalMoves ?? this.totalMoves,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'coins': coins,
      'completedLevels': completedLevels,
      'completedDailies': completedDailies,
      'totalMoves': totalMoves,
      'bestStreak': bestStreak,
      'currentStreak': currentStreak,
      'totalPlayTime': totalPlayTime,
      'totalHintsUsed': totalHintsUsed,
      'lastPlayedDate': lastPlayedDate,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentLevel: json['currentLevel'] as int? ?? 1,
      coins: json['coins'] as int? ?? 200,
      completedLevels: List<int>.from(json['completedLevels'] as List? ?? const []),
      completedDailies: List<String>.from(json['completedDailies'] as List? ?? const []),
      totalMoves: json['totalMoves'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalPlayTime: json['totalPlayTime'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] as String? ?? '',
    );
  }
}

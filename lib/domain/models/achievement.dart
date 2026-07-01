class Achievement {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final int rewardCoins;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    required this.rewardCoins,
  });

  bool get progressFinished => currentValue >= targetValue;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    int? rewardCoins,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      rewardCoins: rewardCoins ?? this.rewardCoins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked,
      'rewardCoins': rewardCoins,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      rewardCoins: json['rewardCoins'] as int? ?? 50,
    );
  }

  static List<Achievement> get defaultAchievements => [
        const Achievement(
          id: 'first_level',
          title: 'First Step',
          description: 'Complete your first level',
          targetValue: 1,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 50,
        ),
        const Achievement(
          id: 'ten_levels',
          title: 'Pour Master',
          description: 'Complete 10 levels',
          targetValue: 10,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 100,
        ),
        const Achievement(
          id: 'fifty_levels',
          title: 'Sort Legend',
          description: 'Complete 50 levels',
          targetValue: 50,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 250,
        ),
        const Achievement(
          id: 'efficiency',
          title: 'Efficiency Expert',
          description: 'Complete a level in less than 12 moves',
          targetValue: 1,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 150,
        ),
        const Achievement(
          id: 'first_hint',
          title: 'Seeking Guidance',
          description: 'Use your first hint',
          targetValue: 1,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 50,
        ),
        const Achievement(
          id: 'daily_challenge',
          title: 'Daily Sort',
          description: 'Solve a Daily Challenge',
          targetValue: 1,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 100,
        ),
        const Achievement(
          id: 'streak_3',
          title: 'Dedication',
          description: 'Reach a 3-day streak',
          targetValue: 3,
          currentValue: 0,
          isUnlocked: false,
          rewardCoins: 150,
        ),
      ];
}

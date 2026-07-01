class Move {
  final int fromBottleId;
  final int toBottleId;
  final int color;
  final int count;

  const Move({
    required this.fromBottleId,
    required this.toBottleId,
    required this.color,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromBottleId': fromBottleId,
      'toBottleId': toBottleId,
      'color': color,
      'count': count,
    };
  }

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      fromBottleId: json['fromBottleId'] as int,
      toBottleId: json['toBottleId'] as int,
      color: json['color'] as int,
      count: json['count'] as int,
    );
  }

  @override
  String toString() => 'Move(from: $fromBottleId, to: $toBottleId, color: $color, count: $count)';
}

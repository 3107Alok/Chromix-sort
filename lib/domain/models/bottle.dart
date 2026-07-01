class Bottle {
  final int id;
  final List<int> layers; // Maximum length of 4. Integer represents color ID.
  final int capacity;

  const Bottle({
    required this.id,
    required this.layers,
    this.capacity = 4,
  });

  bool get isEmpty => layers.isEmpty;
  bool get isFull => layers.length >= capacity;

  // A bottle is completed if it's full AND all layers are the same color.
  bool get isComplete {
    if (layers.isEmpty) return true; // Empty is solved/complete in some contexts, but let's check
    if (layers.length < capacity) return false;
    final first = layers.first;
    return layers.every((c) => c == first);
  }

  // Returns true if the bottle contains only one color (not necessarily full).
  bool get isSingleColor {
    if (layers.isEmpty) return true;
    final first = layers.first;
    return layers.every((c) => c == first);
  }

  int get topColor => layers.isEmpty ? -1 : layers.last;

  // Count how many consecutive top layers have the same color.
  int get topColorCount {
    if (layers.isEmpty) return 0;
    final target = layers.last;
    int count = 0;
    for (int i = layers.length - 1; i >= 0; i--) {
      if (layers[i] == target) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int get spaceAvailable => capacity - layers.length;

  bool canAdd(int color) {
    if (isFull) return false;
    if (isEmpty) return true;
    return topColor == color;
  }

  Bottle copyWith({
    int? id,
    List<int>? layers,
    int? capacity,
  }) {
    return Bottle(
      id: id ?? this.id,
      layers: layers ?? List.from(this.layers),
      capacity: capacity ?? this.capacity,
    );
  }

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layers': layers,
      'capacity': capacity,
    };
  }

  factory Bottle.fromJson(Map<String, dynamic> json) {
    return Bottle(
      id: json['id'] as int,
      layers: List<int>.from(json['layers'] as List),
      capacity: json['capacity'] as int? ?? 4,
    );
  }

  @override
  String toString() => 'Bottle(id: $id, layers: $layers)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bottle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          _listEquals(layers, other.layers) &&
          capacity == other.capacity;

  @override
  int get hashCode => id.hashCode ^ _listHash(layers) ^ capacity.hashCode;

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHash(List<int> list) {
    return list.fold(0, (hash, element) => hash ^ element.hashCode);
  }
}

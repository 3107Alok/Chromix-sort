class GameSettings {
  final bool musicOn;
  final bool soundOn;
  final bool hapticOn;
  final bool darkMode;
  final String language;

  const GameSettings({
    this.musicOn = true,
    this.soundOn = true,
    this.hapticOn = true,
    this.darkMode = true,
    this.language = 'en',
  });

  GameSettings copyWith({
    bool? musicOn,
    bool? soundOn,
    bool? hapticOn,
    bool? darkMode,
    String? language,
  }) {
    return GameSettings(
      musicOn: musicOn ?? this.musicOn,
      soundOn: soundOn ?? this.soundOn,
      hapticOn: hapticOn ?? this.hapticOn,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'musicOn': musicOn,
      'soundOn': soundOn,
      'hapticOn': hapticOn,
      'darkMode': darkMode,
      'language': language,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      musicOn: json['musicOn'] as bool? ?? true,
      soundOn: json['soundOn'] as bool? ?? true,
      hapticOn: json['hapticOn'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
    );
  }
}

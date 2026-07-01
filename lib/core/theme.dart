import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  // Dark premium space gradient background colors
  static const Color bgStart = Color(0xFF13092A); // Very deep purple
  static const Color bgEnd = Color(0xFF070211);   // Near black purple

  // Accent Colors
  static const Color accentGlow = Color(0xFF8B5CF6); // Vibrant violet glow
  static const Color coinGold = Color(0xFFFFD700);  // Gold for coins
  static const Color buttonGlass = Color(0x15FFFFFF); // Transparent glass
  static const Color borderGlass = Color(0x25FFFFFF); // Translucent border

  // Premium liquid gradients (color ID -> gradient)
  static final Map<int, List<Color>> liquidGradients = {
    1: [const Color(0xFFFF2E93), const Color(0xFFFF8A00)], // Sunset Red/Orange
    2: [const Color(0xFF00F0FF), const Color(0xFF0072FF)], // Radiant Cyan/Blue
    3: [const Color(0xFF00FF87), const Color(0xFF60EFFF)], // Electric Mint/Teal
    4: [const Color(0xFFFFE53B), const Color(0xFFFF2525)], // Hot Gold/Fire Red
    5: [const Color(0xFFBF5AE0), const Color(0xFFE60067)], // Royal Purple/Pink
    6: [const Color(0xFF9B00E8), const Color(0xFF00E1FF)], // Cosmos Purple/Cyan
    7: [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Lush Green/Teal
    8: [const Color(0xFFFFE000), const Color(0xFF799F0C)], // Lime Yellow/Green
    9: [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)], // Lavender/Soft Sky
    10: [const Color(0xFFFBC2EB), const Color(0xFFA6C1EE)], // Rose Gold/Blue Tint
  };

  /// Returns a paint shader or list of colors for liquid layers.
  static List<Color> getLiquidColors(int colorId) {
    return liquidGradients[colorId] ?? [const Color(0xFF888888), const Color(0xFFCCCCCC)];
  }

  /// Neon shadow for buttons and active items
  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: accentGlow.withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];

  /// Soft glassmorphism background style
  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color color = Colors.white10,
    double borderOpacity = 0.15,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Dark Theme Data configuration
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
    );
  }
}

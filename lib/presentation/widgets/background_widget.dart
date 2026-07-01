import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BackgroundWidget extends StatefulWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  State<BackgroundWidget> createState() => _BackgroundWidgetState();
}

class _BackgroundWidgetState extends State<BackgroundWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_StarParticle> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate 35 random star particles
    for (int i = 0; i < 35; i++) {
      _stars.add(_StarParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 0.8,
        speed: _random.nextDouble() * 0.02 + 0.005,
        maxOpacity: _random.nextDouble() * 0.6 + 0.2,
        pulseSpeed: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameTheme.bgStart, GameTheme.bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // Floating stars layer
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StarsPainter(_stars, _controller.value),
                  size: Size.infinite,
                );
              },
            ),
            // The content on top
            SafeArea(child: widget.child),
          ],
        ),
      ),
    );
  }
}

class _StarParticle {
  double x; // Percentage (0.0 to 1.0)
  double y; // Percentage (0.0 to 1.0)
  final double size;
  final double speed;
  final double maxOpacity;
  final double pulseSpeed;

  _StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.maxOpacity,
    required this.pulseSpeed,
  });

  void update(double value) {
    // Slowly drift upwards
    y -= speed * 0.01;
    if (y < 0) {
      y = 1.0;
      x = Random().nextDouble();
    }
  }
}

class _StarsPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double animationValue;

  _StarsPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      star.update(animationValue);

      // Pulse opacity based on sine wave
      final pulse = sin(animationValue * 2 * pi * star.pulseSpeed);
      final opacity = (star.maxOpacity * (0.5 + 0.5 * pulse)).clamp(0.0, 1.0);
      
      paint.color = Colors.white.withOpacity(opacity);

      // Draw star coordinate
      final screenX = star.x * size.width;
      final screenY = star.y * size.height;

      // Draw a soft glowing circle
      canvas.drawCircle(Offset(screenX, screenY), star.size, paint);
      
      // If star is larger, draw a tiny glow around it
      if (star.size > 2.0) {
        final glowPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = GameTheme.accentGlow.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(screenX, screenY), star.size * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}

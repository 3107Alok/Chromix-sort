import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models/bottle.dart';

class BottleWidget extends StatelessWidget {
  final Bottle bottle;
  final bool isSelected;
  final double tiltAngle; // in radians
  final double fillPercentageOffset; // for animating volume changes locally
  final int animatingLayerColor; // color of the layer being animated

  const BottleWidget({
    super.key,
    required this.bottle,
    this.isSelected = false,
    this.tiltAngle = 0.0,
    this.fillPercentageOffset = 0.0,
    this.animatingLayerColor = -1,
  });

  @override
  Widget build(BuildContext context) {
    // We wrap the custom paint in a RepaintBoundary.
    // This instructs Flutter to cache the rendered texture of this bottle
    // and only repaint it if the parameters actually change.
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -15.0 : 0.0), // Hover effect
        child: CustomPaint(
          size: const Size(60, 160),
          painter: _BottlePainter(
            layers: bottle.layers,
            capacity: bottle.capacity,
            isSelected: isSelected,
            tiltAngle: tiltAngle,
            fillPercentageOffset: fillPercentageOffset,
            animatingLayerColor: animatingLayerColor,
          ),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final List<int> layers;
  final int capacity;
  final bool isSelected;
  final double tiltAngle;
  final double fillPercentageOffset;
  final int animatingLayerColor;

  _BottlePainter({
    required this.layers,
    required this.capacity,
    required this.isSelected,
    required this.tiltAngle,
    required this.fillPercentageOffset,
    required this.animatingLayerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // We want to draw a glass bottle structure
    // Neck: top 25px
    // Body: remaining 135px
    final neckHeight = 25.0;
    final neckWidth = 20.0;
    final bodyHeight = h - neckHeight;
    final cornerRadius = 15.0;

    canvas.save();
    
    // Handle tilt rotation around the mouth/neck top center
    if (tiltAngle != 0.0) {
      canvas.translate(w / 2, 0);
      canvas.rotate(tiltAngle);
      canvas.translate(-w / 2, 0);
    }

    // 1. Create clipping path for the INNER area of the bottle (to clip liquid)
    final innerPath = Path();
    // Neck inner bounds
    final neckLeft = (w - neckWidth) / 2 + 1.5;
    final neckRight = w - neckLeft;
    
    innerPath.moveTo(neckLeft, 2.0);
    innerPath.lineTo(neckRight, 2.0);
    innerPath.lineTo(neckRight, neckHeight);
    
    // Smooth transition from neck to body
    innerPath.lineTo(w - 2.0, neckHeight + 8.0);
    
    // Body inner bounds
    innerPath.lineTo(w - 2.0, h - cornerRadius);
    innerPath.arcToPoint(
      Offset(w - cornerRadius, h - 2.0),
      radius: Radius.circular(cornerRadius - 2.0),
      clockwise: true,
    );
    innerPath.lineTo(cornerRadius, h - 2.0);
    innerPath.arcToPoint(
      Offset(2.0, h - cornerRadius),
      radius: Radius.circular(cornerRadius - 2.0),
      clockwise: true,
    );
    innerPath.lineTo(2.0, neckHeight + 8.0);
    innerPath.lineTo(neckLeft, neckHeight);
    innerPath.close();

    // 2. Draw Liquid Layers inside the inner bounds
    canvas.save();
    canvas.clipPath(innerPath);

    final numLayers = layers.length;
    if (numLayers > 0) {
      // Calculate how high the liquid is
      final maxLiquidHeight = bodyHeight - 10.0; // leave some space at the top of the body
      final layerHeight = maxLiquidHeight / capacity;

      double currentY = h - 2.0;

      for (int i = 0; i < numLayers; i++) {
        final colorId = layers[i];
        
        // Handle height animation if this is the animating top layer
        double currentLayerHeight = layerHeight;
        if (i == numLayers - 1 && fillPercentageOffset != 0.0) {
          currentLayerHeight = layerHeight + (fillPercentageOffset * layerHeight);
          // Clamp so it doesn't go negative or overflow
          if (currentLayerHeight < 0) currentLayerHeight = 0;
        }

        if (currentLayerHeight > 0) {
          final topY = currentY - currentLayerHeight;

          // Liquid paint with gradient
          final colors = GameTheme.getLiquidColors(colorId);
          final paint = Paint()
            ..style = PaintingStyle.fill
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ).createShader(Rect.fromLTRB(2.0, topY, w - 2.0, currentY));

          // Draw the liquid block
          final rectPath = Path();
          rectPath.moveTo(1.0, currentY + 1.0);
          rectPath.lineTo(w - 1.0, currentY + 1.0);
          rectPath.lineTo(w - 1.0, topY);
          
          // Surface tension meniscus (curved top)
          rectPath.quadraticBezierTo(w / 2, topY - 3.0, 1.0, topY);
          rectPath.close();

          canvas.drawPath(rectPath, paint);

          // Add a subtle bubble/glowing effect inside the liquid layer
          final shinePaint = Paint()
            ..style = PaintingStyle.fill
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.15), Colors.transparent],
            ).createShader(Rect.fromLTRB(2.0, topY, w - 2.0, topY + 8));
          canvas.drawRect(Rect.fromLTRB(2.0, topY, w - 2.0, topY + 8), shinePaint);

          currentY = topY;
        }
      }
    }
    canvas.restore(); // end of liquid clipping

    // 3. Draw Glass Bottle Frame on top of liquid
    final borderPath = Path();
    final outerNeckLeft = (w - neckWidth) / 2;
    final outerNeckRight = w - outerNeckLeft;

    borderPath.moveTo(outerNeckLeft, 0.0);
    borderPath.lineTo(outerNeckRight, 0.0);
    borderPath.lineTo(outerNeckRight, neckHeight);
    borderPath.lineTo(w, neckHeight + 8.0);
    borderPath.lineTo(w, h - cornerRadius);
    borderPath.arcToPoint(
      Offset(w - cornerRadius, h),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    borderPath.lineTo(cornerRadius, h);
    borderPath.arcToPoint(
      Offset(0.0, h - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    borderPath.lineTo(0.0, neckHeight + 8.0);
    borderPath.lineTo(outerNeckLeft, neckHeight);
    borderPath.close();

    // Soft white transparent glass body paint
    final glassBodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.06);
    canvas.drawPath(borderPath, glassBodyPaint);

    // Glowing border if selected, otherwise normal border
    final glassBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5
      ..color = isSelected 
          ? GameTheme.accentGlow.withOpacity(0.9) 
          : Colors.white.withOpacity(0.25);

    // If selected, apply shadow glow to the canvas
    if (isSelected) {
      final shadowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..color = GameTheme.accentGlow.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(borderPath, shadowPaint);
    }

    canvas.drawPath(borderPath, glassBorderPaint);

    // 4. Draw Reflection Highlights (makes it look premium & glassy)
    final reflectionPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTRB(4.0, neckHeight + 10.0, 12.0, h - 15.0));

    final reflectionPath = Path()
      ..moveTo(4.0, neckHeight + 10.0)
      ..lineTo(9.0, neckHeight + 10.0)
      ..lineTo(9.0, h - 20.0)
      ..arcToPoint(Offset(4.0, h - cornerRadius), radius: Radius.circular(cornerRadius - 5.0))
      ..close();
    canvas.drawPath(reflectionPath, reflectionPaint);

    // Small highlight on the neck
    canvas.drawRect(
      Rect.fromLTRB(outerNeckLeft + 3, 5, outerNeckLeft + 6, neckHeight - 3),
      Paint()..color = Colors.white.withOpacity(0.15),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.capacity != capacity ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.tiltAngle != tiltAngle ||
        oldDelegate.fillPercentageOffset != fillPercentageOffset ||
        oldDelegate.animatingLayerColor != animatingLayerColor;
  }
}

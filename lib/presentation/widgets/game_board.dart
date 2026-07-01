import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models/bottle.dart';
import '../../domain/engine/move_validator.dart';
import 'bottle_widget.dart';

class GameBoard extends StatefulWidget {
  final List<Bottle> bottles;
  final int? selectedBottleId;
  final int movesCount;
  final Function(int) onBottleTap;
  final VoidCallback? onAnimationComplete;

  const GameBoard({
    super.key,
    required this.bottles,
    required this.selectedBottleId,
    required this.movesCount,
    required this.onBottleTap,
    this.onAnimationComplete,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {
  late AnimationController _pourController;
  
  // Animation variables
  bool _isAnimating = false;
  int _animatingSourceId = -1;
  int _animatingTargetId = -1;
  int _pourColor = -1;
  int _pourAmount = 0;

  // Screen offsets
  Offset _sourceGlobalOffset = Offset.zero;
  Offset _targetGlobalOffset = Offset.zero;

  // Local state copy to freeze grid positions during pour
  List<Bottle> _localBottles = [];
  int _prevMovesCount = 0;

  // Keys to obtain coordinates
  final Map<int, GlobalKey> _bottleKeys = {};

  @override
  void initState() {
    super.initState();
    _localBottles = List.from(widget.bottles);
    _prevMovesCount = widget.movesCount;
    _pourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pourController.addListener(() {
      setState(() {});
    });

    _pourController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _localBottles = List.from(widget.bottles);
          _animatingSourceId = -1;
          _animatingTargetId = -1;
          _pourController.reset();
        });
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if a move happened
    if (widget.movesCount > _prevMovesCount) {
      // Find the difference to animate
      _detectAndTriggerPour(oldWidget.bottles, widget.bottles);
    } else if (!_isAnimating) {
      _localBottles = List.from(widget.bottles);
    }
    _prevMovesCount = widget.movesCount;
  }

  void _detectAndTriggerPour(List<Bottle> oldBottles, List<Bottle> newBottles) {
    int srcId = -1;
    int destId = -1;

    for (int i = 0; i < oldBottles.length; i++) {
      final oldB = oldBottles[i];
      final newB = newBottles.firstWhere((b) => b.id == oldB.id, orElse: () => oldB);
      
      if (newB.layers.length < oldB.layers.length) {
        srcId = oldB.id;
      } else if (newB.layers.length > oldB.layers.length) {
        destId = oldB.id;
      }
    }

    if (srcId != -1 && destId != -1) {
      // Fetch coordinates
      final srcKey = _bottleKeys[srcId];
      final destKey = _bottleKeys[destId];

      if (srcKey != null && destKey != null &&
          srcKey.currentContext != null && destKey.currentContext != null) {
        
        final srcBox = srcKey.currentContext!.findRenderObject() as RenderBox;
        final destBox = destKey.currentContext!.findRenderObject() as RenderBox;
        
        final srcPos = srcBox.localToGlobal(Offset.zero);
        final destPos = destBox.localToGlobal(Offset.zero);

        // Find color and amount of pour
        final oldSrc = oldBottles.firstWhere((b) => b.id == srcId);
        final newSrc = newBottles.firstWhere((b) => b.id == srcId);
        
        _pourColor = oldSrc.topColor;
        _pourAmount = oldSrc.layers.length - newSrc.layers.length;

        // Set up coordinates relative to this parent board widget
        final boardBox = context.findRenderObject() as RenderBox;
        final boardPos = boardBox.localToGlobal(Offset.zero);

        setState(() {
          _localBottles = List.from(oldBottles); // Freeze at old state
          _isAnimating = true;
          _animatingSourceId = srcId;
          _animatingTargetId = destId;
          _sourceGlobalOffset = srcPos - boardPos;
          _targetGlobalOffset = destPos - boardPos;
        });

        _pourController.forward();
        return;
      }
    }

    // Fallback if coordinates fail: update directly
    setState(() {
      _localBottles = List.from(widget.bottles);
    });
  }

  @override
  void dispose() {
    _pourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate keys for any new bottles
    for (final bottle in widget.bottles) {
      _bottleKeys.putIfAbsent(bottle.id, () => GlobalKey());
    }

    // Grid layout calculations:
    // Support portrait mode on phones/tablets.
    // If we have <= 6 bottles, show in 1 row.
    // If we have > 6 bottles, show in 2 rows.
    final totalBottles = _localBottles.length;
    final row1Count = (totalBottles <= 6) ? totalBottles : (totalBottles / 2).ceil();
    final row2Count = totalBottles - row1Count;

    final row1Bottles = _localBottles.take(row1Count).toList();
    final row2Bottles = _localBottles.skip(row1Count).toList();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Grid of Bottles
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row1Bottles.map((b) => _buildGridBottle(b)).toList(),
            ),
            if (row2Count > 0) ...[
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row2Bottles.map((b) => _buildGridBottle(b)).toList(),
              ),
            ],
          ],
        ),

        // 2. Flying pouring bottle overlay
        if (_isAnimating) _buildPouringOverlay(),
      ],
    );
  }

  Widget _buildGridBottle(Bottle bottle) {
    final key = _bottleKeys[bottle.id]!;
    
    // Hide bottle inside grid if it is flying/pouring
    final hide = _isAnimating && (bottle.id == _animatingSourceId);

    // Animate target bottle filling up gradually during pour phase
    double fillOffset = 0.0;
    int animatingColor = -1;

    if (_isAnimating && bottle.id == _animatingTargetId) {
      final progress = _pourController.value;
      if (progress >= 0.3 && progress <= 0.75) {
        // Pour phase
        final pourProgress = (progress - 0.3) / 0.45; // 0.0 to 1.0
        fillOffset = -_pourAmount.toDouble() * (1.0 - pourProgress);
        animatingColor = _pourColor;
      }
    }

    return GestureDetector(
      key: key,
      onTap: _isAnimating ? null : () => widget.onBottleTap(bottle.id),
      child: Opacity(
        opacity: hide ? 0.0 : 1.0,
        child: BottleWidget(
          bottle: bottle,
          isSelected: widget.selectedBottleId == bottle.id,
          fillPercentageOffset: fillOffset,
          animatingLayerColor: animatingColor,
        ),
      ),
    );
  }

  Widget _buildPouringOverlay() {
    final progress = _pourController.value;

    Offset position = _sourceGlobalOffset;
    double tilt = 0.0;
    double srcFillOffset = 0.0;

    // Phase 1: Lift & Move (0.0 to 0.3)
    if (progress < 0.3) {
      final t = progress / 0.3;
      // Hover source bottle above and to the left of target mouth
      final destinationOffset = _targetGlobalOffset + const Offset(-45, -110);
      position = Offset.lerp(_sourceGlobalOffset, destinationOffset, Curves.easeInOut.transform(t))!;
      // Slightly lift up
      position += Offset(0, -15 * sin(t * pi));
    }
    // Phase 2: Pour (0.3 to 0.75)
    else if (progress <= 0.75) {
      final t = (progress - 0.3) / 0.45; // 0.0 to 1.0
      position = _targetGlobalOffset + const Offset(-45, -110);
      
      // Tilt from 0 to 95 degrees (1.65 radians)
      tilt = 1.65 * Curves.easeOut.transform(t);
      
      // Decrease source liquid level
      srcFillOffset = -_pourAmount.toDouble() * t;
    }
    // Phase 3: Return & Lower (0.75 to 1.0)
    else {
      final t = (progress - 0.75) / 0.25; // 0.0 to 1.0
      final hoverOffset = _targetGlobalOffset + const Offset(-45, -110);
      
      position = Offset.lerp(hoverOffset, _sourceGlobalOffset, Curves.easeInOut.transform(t))!;
      tilt = 1.65 * (1.0 - t);
      srcFillOffset = -_pourAmount.toDouble();
    }

    // Source bottle in current transition state
    final sourceBottle = _localBottles.firstWhere((b) => b.id == _animatingSourceId);

    // Liquid stream rendering during pour phase
    Widget? streamWidget;
    if (progress >= 0.33 && progress <= 0.75) {
      // Calculate coordinates of source mouth and target mouth
      // Source mouth is rotated. Let's make a simplified stream connecting
      // the source pouring location to the target bottle top.
      final streamStart = position + const Offset(55, 30); // Mouth position when tilted
      final streamEnd = _targetGlobalOffset + const Offset(30, 25);   // Target mouth top center
      
      streamWidget = CustomPaint(
        painter: _StreamPainter(
          start: streamStart,
          end: streamEnd,
          colorId: _pourColor,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (streamWidget != null) streamWidget,
        Positioned(
          left: position.dx,
          top: position.dy,
          child: BottleWidget(
            bottle: sourceBottle,
            isSelected: false,
            tiltAngle: tilt,
            fillPercentageOffset: srcFillOffset,
            animatingLayerColor: _pourColor,
          ),
        ),
      ],
    );
  }
}

class _StreamPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final int colorId;

  _StreamPainter({
    required this.start,
    required this.end,
    required this.colorId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = GameTheme.getLiquidColors(colorId);
    
    // Gradient along the vertical flow direction
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromPoints(start, end));

    // Outer glow for the stream
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..color = colors.first.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Draw tiny water droplets splashes at target top mouth
    final splashPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = colors.last;
    
    final random = Random(42); // deterministic splashes
    for (int i = 0; i < 4; i++) {
      final dx = end.dx + (random.nextDouble() * 12 - 6);
      final dy = end.dy + (random.nextDouble() * -8);
      canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 2 + 1, splashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StreamPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end || oldDelegate.colorId != colorId;
  }
}

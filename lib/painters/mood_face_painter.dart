import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moodtracker/models/mood_entry.dart';

class MoodFace extends StatefulWidget {
  final MoodType type;
  final double size;

  const MoodFace({
    super.key,
    required this.type,
    this.size = 100.0,
  });

  @override
  State<MoodFace> createState() => _MoodFaceState();
}

class _MoodFaceState extends State<MoodFace> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _blinkController;
  
  @override
  void initState() {
    super.initState();
    
    // Main controller for floating and liquid animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Blink controller (periodically blinks)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _startBlinking();
  }

  void _startBlinking() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(3000)));
      if (mounted) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _blinkController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Particle layer
            ...List.generate(5, (index) {
              final progress = (_mainController.value + (index / 5)) % 1.0;
              final opacity = (1.0 - progress) * 0.5;
              final color = MoodEntry.getColor(widget.type);
              
              return Positioned(
                bottom: widget.size * 0.2 + (progress * widget.size * 0.6),
                left: widget.size * 0.1 + (sin(progress * 4 * pi + index) * widget.size * 0.2) + (widget.size * 0.35),
                child: Container(
                  width: 4 + (index % 4).toDouble(),
                  height: 4 + (index % 4).toDouble(),
                  decoration: BoxDecoration(
                    color: color.withOpacity(opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(opacity),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              );
            }),
            
            // Mood face layer
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: MoodFacePainter(
                type: widget.type,
                blinkValue: _blinkController.value,
                animationValue: _mainController.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class MoodFacePainter extends CustomPainter {
  final MoodType type;
  final double blinkValue;
  final double animationValue;

  MoodFacePainter({
    required this.type,
    required this.blinkValue,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(size.width, size.height) / 2;
    
    // Subtle float offset
    final floatY = sin(animationValue * 2 * pi) * (radius * 0.05);
    final center = Offset(centerX, centerY + floatY);

    final color = MoodEntry.getColor(type);

    // 1. Draw Face with Gradient
    final facePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.6),
          color.withOpacity(0.4),
        ],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, facePaint);

    // 2. Liquid Fill Effect (Unique Animation)
    _drawLiquidFill(canvas, center, radius, color);

    // 3. Draw Cheeks (Realistic Visual)
    if (type == MoodType.happy) {
      final cheekPaint = Paint()
        ..color = Colors.pinkAccent.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(Offset(center.dx - radius * 0.5, center.dy + radius * 0.1), radius * 0.2, cheekPaint);
      canvas.drawCircle(Offset(center.dx + radius * 0.5, center.dy + radius * 0.1), radius * 0.2, cheekPaint);
    }

    // 4. Draw Eyes with Blinking and Reflections
    _drawEyes(canvas, center, radius);

    // 5. Draw Mouth
    _drawMouth(canvas, center, radius);
  }

  void _drawLiquidFill(Canvas canvas, Offset center, double radius, Color color) {
    final liquidPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double waveHeight = radius * 0.1;
    final double fillLevel = radius * 0.4; // Fill up to 40% from bottom

    path.moveTo(center.dx - radius, center.dy + radius);
    
    for (double x = 0; x <= radius * 2; x++) {
      final double y = sin((animationValue * 2 * pi) + (x / radius * pi)) * waveHeight;
      path.lineTo(center.dx - radius + x, center.dy + fillLevel + y);
    }

    path.lineTo(center.dx + radius, center.dy + radius);
    path.close();

    // Clip to face circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawPath(path, liquidPaint);
    canvas.restore();
  }

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeWidth = radius * 0.18;
    final eyeHeight = radius * (0.28 * (1 - blinkValue)); // Blinking effect
    final eyeOffsetX = radius * 0.35;
    final eyeOffsetY = radius * 0.2;

    if (eyeHeight > 2) {
      // Left eye
      final leftEyeCenter = Offset(center.dx - eyeOffsetX, center.dy - eyeOffsetY);
      canvas.drawOval(
        Rect.fromCenter(center: leftEyeCenter, width: eyeWidth, height: eyeHeight),
        eyePaint,
      );

      // Right eye
      final rightEyeCenter = Offset(center.dx + eyeOffsetX, center.dy - eyeOffsetY);
      canvas.drawOval(
        Rect.fromCenter(center: rightEyeCenter, width: eyeWidth, height: eyeHeight),
        eyePaint,
      );

      // Eye Reflections (Realistic Visual)
      final reflectionPaint = Paint()..color = Colors.white.withOpacity(0.8);
      canvas.drawCircle(
        Offset(leftEyeCenter.dx - eyeWidth * 0.2, leftEyeCenter.dy - eyeHeight * 0.2),
        eyeWidth * 0.2,
        reflectionPaint,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx - eyeWidth * 0.2, rightEyeCenter.dy - eyeHeight * 0.2),
        eyeWidth * 0.2,
        reflectionPaint,
      );
    } else {
      // Draw closed eye line
      final closedEyePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(center.dx - eyeOffsetX - eyeWidth/2, center.dy - eyeOffsetY),
        Offset(center.dx - eyeOffsetX + eyeWidth/2, center.dy - eyeOffsetY),
        closedEyePaint,
      );
      canvas.drawLine(
        Offset(center.dx + eyeOffsetX - eyeWidth/2, center.dy - eyeOffsetY),
        Offset(center.dx + eyeOffsetX + eyeWidth/2, center.dy - eyeOffsetY),
        closedEyePaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset center, double radius) {
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final mouthY = center.dy + radius * 0.3;
    final mouthWidth = radius * 0.5;
    
    // Subtle mouth motion
    final motion = sin(animationValue * 4 * pi) * (radius * 0.02);

    switch (type) {
      case MoodType.happy:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, mouthY + motion),
            width: mouthWidth,
            height: radius * 0.4 + motion,
          ),
          0,
          pi,
          false,
          mouthPaint,
        );
        break;
      case MoodType.neutral:
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, mouthY + radius * 0.1),
          Offset(center.dx + mouthWidth / 2, mouthY + radius * 0.1 + motion),
          mouthPaint,
        );
        break;
      case MoodType.sad:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, mouthY + radius * 0.2 + motion),
            width: mouthWidth,
            height: radius * 0.3,
          ),
          pi,
          pi,
          false,
          mouthPaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant MoodFacePainter oldDelegate) {
    return oldDelegate.type != type || 
           oldDelegate.blinkValue != blinkValue || 
           oldDelegate.animationValue != animationValue;
  }
}

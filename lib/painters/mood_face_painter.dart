import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moodtracker/models/mood_entry.dart';

class MoodFace extends StatelessWidget {
  final MoodType type;
  final double size;

  const MoodFace({
    super.key,
    required this.type,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: MoodFacePainter(type: type),
    );
  }
}

class MoodFacePainter extends CustomPainter {
  final MoodType type;

  MoodFacePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(size.width, size.height) / 2;

    final paint = Paint()
      ..color = MoodEntry.getColor(type)
      ..style = PaintingStyle.fill;

    // Draw Face Circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw Eyes
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeWidth = radius * 0.15;
    final eyeHeight = radius * 0.25;
    final eyeOffsetX = radius * 0.35;
    final eyeOffsetY = radius * 0.2;

    // Left eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - eyeOffsetX, centerY - eyeOffsetY),
        width: eyeWidth,
        height: eyeHeight,
      ),
      eyePaint,
    );

    // Right eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + eyeOffsetX, centerY - eyeOffsetY),
        width: eyeWidth,
        height: eyeHeight,
      ),
      eyePaint,
    );

    // Draw Mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1
      ..strokeCap = StrokeCap.round;

    final mouthY = centerY + radius * 0.25;
    final mouthWidth = radius * 0.5;

    switch (type) {
      case MoodType.happy:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX, mouthY),
            width: mouthWidth,
            height: radius * 0.4,
          ),
          0,
          pi,
          false,
          mouthPaint,
        );
        break;
      case MoodType.neutral:
        canvas.drawLine(
          Offset(centerX - mouthWidth / 2, mouthY + radius * 0.1),
          Offset(centerX + mouthWidth / 2, mouthY + radius * 0.1),
          mouthPaint,
        );
        break;
      case MoodType.sad:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(centerX, mouthY + radius * 0.2),
            width: mouthWidth,
            height: radius * 0.4,
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
    return oldDelegate.type != type;
  }
}

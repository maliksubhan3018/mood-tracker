import 'package:flutter/material.dart';

enum MoodType {
  happy,
  neutral,
  sad,
}

class MoodEntry {
  final MoodType type;
  final DateTime date;
  final Color color;

  MoodEntry({
    required this.type,
    required this.date,
    required this.color,
  });

  static Color getColor(MoodType type) {
    switch (type) {
      case MoodType.happy:
        return Colors.amber;
      case MoodType.neutral:
        return Colors.blue;
      case MoodType.sad:
        return Colors.grey;
    }
  }
}

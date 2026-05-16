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

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'date': date.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final type = MoodType.values[json['type']];
    return MoodEntry(
      type: type,
      date: DateTime.parse(json['date']),
      color: getColor(type),
    );
  }

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

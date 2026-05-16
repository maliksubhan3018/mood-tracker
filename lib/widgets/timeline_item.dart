import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodtracker/models/mood_entry.dart';
import 'package:moodtracker/painters/mood_face_painter.dart';

class TimelineItem extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;

  const TimelineItem({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('MMM d').format(entry.date),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            MoodFace(type: entry.type, size: 50),
            const SizedBox(height: 12),
            Text(
              DateFormat('h:mm a').format(entry.date),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

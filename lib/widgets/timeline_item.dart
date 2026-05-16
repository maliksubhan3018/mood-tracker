import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moodtracker/controllers/mood_controller.dart';
import 'package:moodtracker/models/mood_entry.dart';
import 'package:moodtracker/painters/mood_face_painter.dart';

class TimelineItem extends StatefulWidget {
  final MoodEntry entry;
  final int index;

  const TimelineItem({
    super.key,
    required this.entry,
    required this.index,
  });

  @override
  State<TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final MoodController moodController = Get.find();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  void _handleLongPress() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Delete Entry?'),
        content: const Text('Are you sure you want to remove this mood from your history?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => moodController.deleteMood(widget.index),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 110,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM d').format(widget.entry.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MoodEntry.getColor(widget.entry.type)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: MoodFace(type: widget.entry.type, size: 45),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  DateFormat('h:mm a').format(widget.entry.date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

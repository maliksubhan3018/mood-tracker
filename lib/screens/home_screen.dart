import 'package:flutter/material.dart';
import 'package:moodtracker/models/mood_entry.dart';
import 'package:moodtracker/painters/mood_face_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MoodType? _selectedMood;
  final List<MoodEntry> _moodEntries = [];

  void _saveMood() {
    if (_selectedMood != null) {
      setState(() {
        _moodEntries.insert(
          0,
          MoodEntry(
            type: _selectedMood!,
            date: DateTime.now(),
            color: MoodEntry.getColor(_selectedMood!),
          ),
        );
        _selectedMood = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MoodType.values.map((type) {
                final isSelected = _selectedMood == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = type;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: MoodEntry.getColor(type).withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: MoodFace(type: type, size: 80),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _selectedMood == null ? null : _saveMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                disabledBackgroundColor: Colors.grey.shade800,
              ),
              child: const Text(
                'Save Mood',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            const Text(
              'Your Timeline will appear here',
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

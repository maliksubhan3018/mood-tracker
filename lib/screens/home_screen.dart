import 'package:flutter/material.dart';
import 'package:moodtracker/models/mood_entry.dart';
import 'package:moodtracker/painters/mood_face_painter.dart';
import 'package:moodtracker/widgets/timeline_item.dart';

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
        SnackBar(
          content: const Text('Mood saved successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show last 7 entries
    final displayEntries = _moodEntries.take(7).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('MOOD TRACKER'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
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
                        child: AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? MoodEntry.getColor(type).withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              border: Border.all(
                                color: isSelected
                                    ? MoodEntry.getColor(type)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: MoodFace(type: type, size: 70),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _selectedMood == null ? null : _saveMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1A2E),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.white10,
                    ),
                    child: const Text(
                      'Save Mood',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (displayEntries.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Last 7 Entries',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayEntries.length,
                        clipBehavior: Clip.none,
                        itemBuilder: (context, index) {
                          return TimelineItem(
                            entry: displayEntries[index],
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    const Opacity(
                      opacity: 0.3,
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.white),
                          SizedBox(height: 12),
                          Text('No mood history yet'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

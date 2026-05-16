import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodtracker/controllers/mood_controller.dart';
import 'package:moodtracker/screens/home_screen.dart';

void main() {
  // Initialize GetX Controller
  Get.put(MoodController());
  runApp(const MoodTrackerApp());
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mood Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const HomeScreen(),
    );
  }
}

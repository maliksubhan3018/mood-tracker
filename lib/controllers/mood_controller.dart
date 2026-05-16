import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moodtracker/models/mood_entry.dart';

class MoodController extends GetxController {
  final RxList<MoodEntry> moodEntries = <MoodEntry>[].obs;
  final Rxn<MoodType> selectedMood = Rxn<MoodType>();
  
  static const String _storageKey = 'mood_entries';

  @override
  void onInit() {
    super.onInit();
    loadMoods();
  }

  // Select a mood with animation flag (will be used in UI)
  void selectMood(MoodType type) {
    selectedMood.value = type;
  }

  // Save mood to memory and storage
  Future<void> saveMood() async {
    if (selectedMood.value != null) {
      final newEntry = MoodEntry(
        type: selectedMood.value!,
        date: DateTime.now(),
        color: MoodEntry.getColor(selectedMood.value!),
      );

      moodEntries.insert(0, newEntry);
      selectedMood.value = null;
      
      await _saveToStorage();
      
      Get.snackbar(
        'Success',
        'Mood saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.deepPurpleAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    }
  }

  // Delete mood from memory and storage
  Future<void> deleteMood(int index) async {
    Get.back(); // Close dialog immediately for better UX
    
    moodEntries.removeAt(index);
    await _saveToStorage();
    
    Get.snackbar(
      'Deleted',
      'Entry removed from history',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
  }

  // Load moods from Shared Preferences
  Future<void> loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_storageKey);
    
    if (storedData != null) {
      final List<dynamic> decodedData = jsonDecode(storedData);
      moodEntries.value = decodedData
          .map((item) => MoodEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  // Helper to save current list to storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      moodEntries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  // Filter for last 7 entries
  List<MoodEntry> get lastSevenEntries => moodEntries.take(7).toList();
}

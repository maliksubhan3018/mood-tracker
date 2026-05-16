import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodtracker/controllers/mood_controller.dart';
import 'package:moodtracker/models/mood_entry.dart';
import 'package:moodtracker/painters/mood_face_painter.dart';
import 'package:moodtracker/widgets/timeline_item.dart';

class HomeScreen extends GetView<MoodController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  
                  // Mood Selection Row with Obx
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: MoodType.values.map((type) {
                      return MoodSelectionItem(
                        type: type,
                        isSelected: controller.selectedMood.value == type,
                        onTap: () => controller.selectMood(type),
                      );
                    }).toList(),
                  )),
                  
                  const SizedBox(height: 20),
                  
                  // Dynamic Feedback Text
                  Obx(() => AnimatedOpacity(
                    opacity: controller.selectedMood.value != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      controller.selectedMood.value != null 
                        ? 'FEELING ${controller.selectedMood.value!.name.toUpperCase()}!'
                        : '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: controller.selectedMood.value != null 
                          ? MoodEntry.getColor(controller.selectedMood.value!)
                          : Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  )),
                  
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    onPressed: () => controller.saveMood(),
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
                  
                  const SizedBox(height: 50),
                  
                  // Last 7 Entries Section
                  Obx(() {
                    final displayEntries = controller.lastSevenEntries;
                    if (displayEntries.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last 7 Entries',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54,
                              letterSpacing: 1.2,
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
                                  index: index,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Opacity(
                        opacity: 0.3,
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.white),
                            SizedBox(height: 12),
                            Text('No mood history yet'),
                          ],
                        ),
                      );
                    }
                  }),
                  
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

class MoodSelectionItem extends StatefulWidget {
  final MoodType type;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodSelectionItem({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<MoodSelectionItem> createState() => _MoodSelectionItemState();
}

class _MoodSelectionItemState extends State<MoodSelectionItem> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutQuint)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_pulseController);

    _glowAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(MoodSelectionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = MoodEntry.getColor(widget.type);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: _glowAnimation.value / 4,
                )
              ] : [],
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? color.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: widget.isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: MoodFace(type: widget.type, size: 70),
              ),
            ),
          );
        },
      ),
    );
  }
}

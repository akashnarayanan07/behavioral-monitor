import 'package:flutter/material.dart';
import '../../database/database_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {

  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    generateAIResponse();
  }

  Future<void> generateAIResponse() async {
    List<Map<String, dynamic>> data =
    await DatabaseService.getLast10();

    if (data.isEmpty) {
      setState(() {
        messages.add("No data available. Start logging your behavior.");
      });
      return;
    }

    double avgSleep = 0;
    double avgScreen = 0;
    double avgWorkout = 0;

    for (var d in data) {
      avgSleep += (d['sleep'] ?? 0);
      avgScreen += (d['screenTime'] ?? 0);
      avgWorkout += (d['workout'] ?? 0);
    }

    avgSleep /= data.length;
    avgScreen /= data.length;
    avgWorkout /= data.length;

    List<String> aiMessages = [];

    aiMessages.add("🧠 Hello! Here's your mental health summary:");

    // Sleep
    if (avgSleep < 6) {
      aiMessages.add("⚠️ You're sleeping less than recommended. Try 7–8 hours.");
    } else {
      aiMessages.add("✅ Your sleep schedule looks good.");
    }

    // Screen
    if (avgScreen > 5) {
      aiMessages.add("⚠️ High screen time detected. Consider reducing it.");
    } else {
      aiMessages.add("✅ Screen usage is under control.");
    }

    // Workout
    if (avgWorkout < 1) {
      aiMessages.add("⚠️ You need more physical activity.");
    } else {
      aiMessages.add("✅ Great job staying active!");
    }

    // Final advice
    if (avgSleep < 5 && avgScreen > 6) {
      aiMessages.add("🧠 If this continues, consider consulting a professional.");
    } else {
      aiMessages.add("💡 Keep maintaining your routine!");
    }

    setState(() {
      messages = aiMessages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                messages[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../database/database_service.dart';

class MoodInputScreen extends StatefulWidget {
  const MoodInputScreen({super.key});

  @override
  State<MoodInputScreen> createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends State<MoodInputScreen> {

  int selectedMood = 0;

  void saveMood() async {

    await DatabaseService.insertMood(selectedMood);

    Navigator.pop(context);

  }

  Widget moodCard(String emoji, String label, int value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = value;
        });
      },
      child: Card(
        color: selectedMood == value
            ? Colors.blue.shade100
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),

              const SizedBox(height: 10),

              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Check"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Text(
              "How are you feeling right now?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [

                moodCard("😊", "Positive", 2),
                moodCard("😐", "Neutral", 0),
                moodCard("😔", "Low", -1),
                moodCard("😣", "Stressful", -2),

              ],
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: saveMood,
              child: const Text("Save Mood"),
            ),

          ],
        ),
      ),
    );
  }
}
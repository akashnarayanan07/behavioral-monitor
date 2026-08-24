import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {

  final sleepController = TextEditingController();
  final workController = TextEditingController();
  final studyController = TextEditingController();
  final workoutController = TextEditingController();
  final screenController = TextEditingController();
  final callsController = TextEditingController();
  final maxCallController = TextEditingController();

  int foodQuality = 2;
  int routineScore = 3;
  int mealSkipped = 0;

  Future<void> saveData() async {
    debugPrint("--- START SAVE PROCESS ---");

    if (sleepController.text.isEmpty ||
        workController.text.isEmpty ||
        studyController.text.isEmpty ||
        workoutController.text.isEmpty ||
        screenController.text.isEmpty ||
        callsController.text.isEmpty ||
        maxCallController.text.isEmpty) {

      debugPrint("Validation failed: Empty fields detected");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      debugPrint("Parsing data...");
      
      final behaviorData = {
        'sleep': double.tryParse(sleepController.text) ?? 0.0,
        'work': double.tryParse(workController.text) ?? 0.0,
        'study': double.tryParse(studyController.text) ?? 0.0,
        'workout': double.tryParse(workoutController.text) ?? 0.0,
        'food': foodQuality,
        'mealSkipped': mealSkipped,
        'routine': routineScore,
        // FIXED: 'screen' changed to 'screenTime' to match DB schema
        'screenTime': double.tryParse(screenController.text) ?? 0.0,
        'calls': int.tryParse(callsController.text) ?? 0,
        // FIXED: 'maxcall' changed to 'maxCallDuration' to match DB schema
        'maxCallDuration': double.tryParse(maxCallController.text) ?? 0.0,
        'date': DateTime.now().toIso8601String(),
      };

      debugPrint("Inserting into DB: $behaviorData");
      
      await DatabaseService.insertBehavior(behaviorData);

      debugPrint("Save successful ✅");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Behavior saved ✅")),
      );

      // Reset UI
      sleepController.clear();
      workController.clear();
      studyController.clear();
      workoutController.clear();
      screenController.clear();
      callsController.clear();
      maxCallController.clear();
      
    } catch (e) {
      debugPrint("ERROR SAVING DATA: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget numberField(TextEditingController controller, String label, {String? suffixText, bool isDecimal = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(isDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Behavior Input"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              sectionTitle("Activity Data", Icons.directions_run),

              numberField(sleepController, "Sleep Hours"),
              numberField(workController, "Work Hours"),
              numberField(studyController, "Study Hours"),
              numberField(workoutController, "Workout Minutes"),

              sectionTitle("Lifestyle", Icons.restaurant),

              const Text("Food Habit"),

              DropdownButtonFormField<int>(
                value: foodQuality,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value:1, child: Text("Unhealthy")),
                  DropdownMenuItem(value:2, child: Text("Moderate")),
                  DropdownMenuItem(value:3, child: Text("Healthy")),
                ],
                onChanged: (value){
                  setState(() {
                    foodQuality = value!;
                  });
                },
              ),

              const SizedBox(height:8),

              const Text("Meal Skipped"),

              DropdownButtonFormField<int>(
                value: mealSkipped,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value:0, child: Text("None")),
                  DropdownMenuItem(value:1, child: Text("Breakfast")),
                  DropdownMenuItem(value:2, child: Text("Lunch")),
                  DropdownMenuItem(value:3, child: Text("Dinner")),
                ],
                onChanged: (value){
                  setState(() {
                    mealSkipped = value!;
                  });
                },
              ),

              sectionTitle("Routine Consistency", Icons.schedule),

              Slider(
                value: routineScore.toDouble(),
                min:1,
                max:5,
                divisions:4,
                label:routineScore.toString(),
                onChanged:(value){
                  setState(() {
                    routineScore = value.toInt();
                  });
                },
              ),

              Text("Routine Score: $routineScore"),

              sectionTitle("Phone Usage", Icons.phone_android),

              numberField(screenController, "Screen Time (hours)"),
              numberField(callsController, "Number of Calls", isDecimal: false),
              numberField(maxCallController, "Max Call Duration (minutes)", suffixText: "min"),

              const SizedBox(height:80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: saveData,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Save Behavior Data"),
          ),
        ),
      ),
    );
  }
}

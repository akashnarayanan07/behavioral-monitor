import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

class UsagePermissionScreen extends StatelessWidget {
  const UsagePermissionScreen({super.key});

  void openUsageSettings() {
    const intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
    );

    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permission Required"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "To monitor screen time, please allow Usage Access permission.",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: openUsageSettings,
              child: const Text("Open Settings"),
            ),

          ],
        ),
      ),
    );
  }
}
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future init(Function(String?) onSelectNotification) async {

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onSelectNotification(response.payload);
      },
    );
  }

  static Future showMoodNotification() async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      "mood_channel",
      "Mood Notifications",
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      "Mood Check",
      "How are you feeling right now?",
      notificationDetails,
      payload: "mood",
    );
  }
}
import 'package:flutter/services.dart';

class ScreenTimeService {

  static const MethodChannel _channel =
  MethodChannel('behavior_monitor/screen_time');

  static Future<int> getScreenTime() async {

    try {

      final int minutes =
      await _channel.invokeMethod('getScreenTime');

      return minutes;

    } catch (e) {

      return 0;

    }

  }

}
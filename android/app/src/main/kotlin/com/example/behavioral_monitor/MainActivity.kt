package com.example.behavioral_monitor

import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {

    private val CHANNEL = "behavior_monitor/screen_time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "getScreenTime") {

                    val usageStatsManager =
                        getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

                    val endTime = System.currentTimeMillis()

                    val calendar = Calendar.getInstance()
                    calendar.set(Calendar.HOUR_OF_DAY, 0)
                    calendar.set(Calendar.MINUTE, 0)
                    calendar.set(Calendar.SECOND, 0)

                    val startTime = calendar.timeInMillis

                    val stats = usageStatsManager.queryUsageStats(
                        UsageStatsManager.INTERVAL_DAILY,
                        startTime,
                        endTime
                    )

                    var totalTime: Long = 0

                    if (stats != null) {
                        for (usage in stats) {
                            totalTime += usage.totalTimeInForeground
                        }
                    }

                    val minutes = (totalTime / 1000 / 60).toInt()

                    result.success(minutes)

                } else {
                    result.notImplemented()
                }

            }
    }
}
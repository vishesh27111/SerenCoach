import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'NotificationService.dart';

class ActivityStorage {
  static const _activitiesKey = 'suggestedActivities';

  static Future<void> saveActivities(List<Map<String, String>> activities) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_activitiesKey, jsonEncode(activities));
    await NotificationService.scheduleAllNotificationsAtOnce(activities); // Schedule immediately
  }

  static Future<List<Map<String, String>>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesString = prefs.getString(_activitiesKey);
    if (activitiesString != null) {
      return List<Map<String, String>>.from(jsonDecode(activitiesString));
    } else {
      return [];
    }
  }
}

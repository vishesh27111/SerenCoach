import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    print('Initializing Notifications...');
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      final bool? initialized = await _notifications.initialize(initSettings);
      print('Notifications initialized: $initialized');
    } catch (e) {
      print('Error initializing notifications: $e');
    }

    tz_data.initializeTimeZones();
    print('Time zones initialized');
  }

  static Future<void> requestPermissions() async {
    try {
      print('Requesting iOS permissions...');
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('iOS permissions requested.');
    } catch (e) {
      print('Error requesting iOS permissions: $e');
    }
  }

  static Future<void> scheduleImmediateAndHourlyNotifications(List<Map<String, String>> activities) async {
    await _notifications.cancelAll(); // Clear previous notifications
    final now = tz.TZDateTime.now(tz.local);

    for (var i = 0; i < activities.length; i++) {
      final activity = activities[i];
      final notificationId = i + 1;

      // Schedule immediate notification
      await _notifications.zonedSchedule(
        notificationId,
        'Suggested Activity',
        activity['activity'] ?? 'Try this activity!',
        now.add(Duration(seconds: 5)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'activity_reminders',
            'Activity Reminders',
            channelDescription: 'Scheduled activity reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Schedule hourly notifications
      await _notifications.zonedSchedule(
        notificationId + 1000, // Unique ID for hourly notification
        'Activity Reminder',
        activity['activity'] ?? 'Keep up your mindfulness!',
        now.add(Duration(hours: i + 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'activity_hourly_reminders',
            'Hourly Activity Reminders',
            channelDescription: 'Hourly reminders for activities',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('Notifications scheduled for activity: ${activity['activity']}');
    }
  }
}

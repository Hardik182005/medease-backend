import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static late GlobalKey<NavigatorState> navigatorKey;

  static Future<void> init() async {
    tz.initializeTimeZones();

    final iosPlugin =
    _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await _initFCM();
  }

  static Future<void> _initFCM() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    final token = await fcm.getToken();
    debugPrint('📬 FCM Token: $token');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground message received: ${message.notification?.title}");

      final notification = message.notification;
      final data = message.data;

      showNotification(
        title: notification?.title ?? data['title'] ?? '💊 Medication Reminder',
        body: notification?.body ?? data['body'] ?? '',
        payload: data['payload'],
        screen: data['screen'],
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final screen = message.data['screen'];
      final payload = message.data['payload'];

      debugPrint("🚀 onMessageOpenedApp: Navigate to $screen with $payload");

      if (screen != null && navigatorKey.currentState != null) {
        navigatorKey.currentState?.pushNamed('/$screen', arguments: payload);
      }
    });
  }

  static Future<void> showNotification({String? title, String? body, String? payload, String? screen}) async {
    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Messages',
      channelDescription: 'Firebase push messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload ?? '',
    );
  }

  static Future<void> _handleNotificationTap(NotificationResponse response) async {
    final payload = response.payload ?? '';
    final action = response.actionId;

    debugPrint("🧭 Notification tapped. Payload: $payload, Action: $action");

    if (payload.isEmpty) return;

    switch (action) {
      case 'confirm':
        await updateReminderStatus(payload, 'confirmed');
        break;
      case 'later':
        await rescheduleReminderLater(payload);
        break;
      case 'skip':
        await updateReminderStatus(payload, 'skipped');
        break;
      default:
        navigatorKey.currentState?.pushNamed('/medication-overview', arguments: payload);
    }
  }

  static Future<void> updateReminderStatus(String docId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('h:mm a').format(now);

      final reminderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(docId);

      final reminder = await reminderRef.get();
      final data = reminder.data();
      if (data == null) return;

      await reminderRef.collection('progress').doc('$dateStr-$timeStr').set({
        'date': dateStr,
        'time': timeStr,
        'status': status,
        'medicineName': data['medicineName'],
        'dose': data['dose'],
        'unit': data['unit'],
        'updatedAt': now.toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error updating progress: $e');
    }
  }

  static Future<void> rescheduleReminderLater(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(docId)
          .get();

      final data = doc.data();
      if (data == null) return;

      final medicineName = data['medicineName'];
      final unit = data['unit'];
      final int dose = data['dose'] ?? 1;

      const title = 'Reminder (Snoozed) 🕒💊';
      final body = '$medicineName $dose $unit';

      await _plugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medease_channel',
            'Medication Reminders',
            channelDescription: 'Medease med reminders',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction('confirm', 'CONFIRM'),
              AndroidNotificationAction('later', '30 MIN LATER'),
              AndroidNotificationAction('skip', 'SKIP'),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: docId,
      );
    } catch (e) {
      debugPrint('❌ Error rescheduling: $e');
    }
  }

  static Future<void> scheduleReminderWithAutoMiss({
    required String docId,
    required String medicineName,
    required String unit,
    required int dose,
    required int hour,
    required int minute,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💊 Time to take $medicineName',
      '$dose $unit',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'multi_reminder_channel',
          'Multiple Daily Reminders',
          channelDescription: 'Reminders for multiple time slots',
          importance: Importance.max,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('confirm', 'CONFIRM'),
            AndroidNotificationAction('later', '30 MIN LATER'),
            AndroidNotificationAction('skip', 'SKIP'),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: docId,
    );

    Future.delayed(const Duration(minutes: 35), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final reminderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(docId)
          .get();

      final reminderData = reminderDoc.data();
      if (reminderData == null) return;

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('h:mm a').format(DateTime.now());

      final progressRef = reminderDoc.reference.collection('progress').doc('$dateStr-$timeStr');
      final progressSnap = await progressRef.get();

      if (!progressSnap.exists) {
        await updateReminderStatus(docId, 'missed');
      }
    });
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    return scheduled.isBefore(now) ? scheduled.add(const Duration(days: 1)) : scheduled;
  }

  static Future<String?> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint("📬 Current FCM Token (manual fetch): $token");
      return token;
    } catch (e) {
      debugPrint("❌ Failed to get FCM token: $e");
      return null;
    }
  }
}

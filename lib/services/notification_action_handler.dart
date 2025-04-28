import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class NotificationActionHandler {
  static Future<void> handleAction(String reminderId, String action) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(reminderId)
          .get();

      if (!doc.exists) return;

      switch (action) {
        case 'confirm':
          await NotificationService.updateReminderStatus(reminderId, 'confirmed');
          break;
        case 'later':
          await NotificationService.rescheduleReminderLater(reminderId);
          break;
        case 'skip':
          await NotificationService.updateReminderStatus(reminderId, 'skipped');
          break;
        default:
          debugPrint("❓ Unknown action: $action");
      }
    } catch (e) {
      debugPrint('❌ Error handling action: $e');
    }
  }
}

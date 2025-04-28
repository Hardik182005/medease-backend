import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder_model.dart';
import 'package:intl/intl.dart';

class ReminderService {
  /// Save a ReminderModel and return its Firestore document ID
  static Future<String> saveReminder(ReminderModel reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final data = reminder.toMap();

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .add(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Save a raw Map with optional fcmToken
  static Future<String> saveReminderMap(Map<String, dynamic> reminderData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .add(reminderData);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all reminders and include document ID
  static Future<List<ReminderModel>> getReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReminderModel.fromMap(data, id: doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update reminder status and log progress
  static Future<void> updateReminderStatus(String docId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('h:mm a').format(now);

      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(docId);

      final doc = await ref.get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      await ref.update({
        'status': status,
        'statusUpdatedAt': now.toIso8601String(),
      });

      await ref.collection('progress').doc('$dateStr-$timeStr').set({
        'date': dateStr,
        'time': timeStr,
        'status': status,
        'medicineName': data['medicineName'],
        'dose': data['dose'],
        'unit': data['unit'],
        'updatedAt': now.toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }
}

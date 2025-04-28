import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  /// Saves the uploaded document's details to Firestore.
  static Future<void> saveUploadedDoc({
    required String url,
    required String docType,
    required String patientName,
    required int age,
    required String publicId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    await FirebaseFirestore.instance.collection('documents').add({
      'url': url,
      'public_id': publicId,
      'category': docType.toLowerCase(),
      'patientName': patientName,
      'age': age,
      'userId': userId,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }
}

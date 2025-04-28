import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Step 1: Send OTP
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String) onAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
    );
  }

  /// Step 2: Sign in using OTP credential
  static Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        // Create an empty profile – to be completed in FullRegisterScreen
        await userRef.set({
          'firstName': '',
          'lastName': '',
          'email': '',
          'dob': '',
          'loginMethod': 'phone',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in using Google and sync to Firestore
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final doc = await userRef.get();

        // Only create profile if not already stored
        if (!doc.exists) {
          final fullName = user.displayName ?? '';
          final nameParts = fullName.split(' ');

          await userRef.set({
            'firstName': nameParts.isNotEmpty ? nameParts.first : '',
            'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            'email': user.email ?? '',
            'dob': '', // Let user fill this later
            'loginMethod': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign out from both Firebase and Google
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Get current signed-in Firebase user
  static User? get currentUser => _auth.currentUser;
}

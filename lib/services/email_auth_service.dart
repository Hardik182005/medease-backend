import 'package:firebase_auth/firebase_auth.dart';

class EmailAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static User? get currentUser => _auth.currentUser;

  static Future<void> signOut() => _auth.signOut();
}

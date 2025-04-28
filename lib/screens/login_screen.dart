import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/google_auth_service.dart';
import '../services/notification_service.dart'; // 👈 Make sure this is imported

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordVisible = false;

  bool get isButtonEnabled =>
      _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;

  Future<void> _signInWithEmailPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _saveFcmToken(); // ✅ Save FCM after login

      Navigator.pushReplacementNamed(context, '/welcome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCred = await GoogleAuthService.signInWithGoogle();
      if (userCred != null) {
        await _saveFcmToken(); // ✅ Save FCM after Google login

        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    }
  }

  /// ✅ Save FCM Token to Firestore under users/{uid}/fcmToken
  Future<void> _saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await NotificationService.getToken();
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
      debugPrint("✅ FCM token saved to Firestore");
    } else {
      debugPrint("⚠️ Could not save FCM token");
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final TextEditingController emailResetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailResetController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailResetController.text.trim();
              if (email.isEmpty) return;

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset link sent. Check your email.')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/landing'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Manrope')),
              const SizedBox(height: 4),
              const Text('Please enter the details to login',
                  style: TextStyle(fontSize: 14, fontFamily: 'Manrope')),
              const SizedBox(height: 24),
              const Text('Email or Username', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('Enter your email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text('Password', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !isPasswordVisible,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('Enter your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text('Forgot Password?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isButtonEnabled ? _signInWithEmailPassword : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E47FF),
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: Image.asset('assets/Images/google.png', height: 20),
                label: const Text('Sign in with Google',
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.apple, color: Colors.white),
                label: const Text('Sign in with Apple',
                    style: TextStyle(fontSize: 14, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D3DCB),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/full-register'),
                  child: const Text("Don't have an account? Register",
                      style: TextStyle(
                          color: Color(0xFF1E47FF), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}

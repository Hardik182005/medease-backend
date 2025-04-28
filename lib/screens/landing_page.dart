import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final userCred = await GoogleAuthService.signInWithGoogle();
      if (userCred != null) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Image.asset(
                'assets/Images/logo_photo.png', // ✅ New image path
                height: 200,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E47FF),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue With Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _handleGoogleSignIn(context),
                    icon: Image.asset('assets/Images/google.png', height: 20),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Apple Sign-In can be added here later
                    },
                    icon: const Icon(Icons.apple, size: 20, color: Colors.white),
                    label: const Text(
                      'Sign in with Apple',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1635CC),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: Color(0xFF1E47FF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'By signing up or logging in, I accept the apps',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  color: Colors.black87,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text.rich(
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Color(0xFF1E47FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF1E47FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

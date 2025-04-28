import 'package:flutter/material.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medeasee/screens/reminder_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCirc,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReminderScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: CircularRevealAnimation(
              animation: _animation,
              centerAlignment: Alignment.center,
              child: Container(
                color: const Color(0xFF254EDB),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hello $userName 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome to MedEase',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

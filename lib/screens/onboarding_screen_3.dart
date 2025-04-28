import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 30),
        Center(
          child: Image(
            image: AssetImage('assets/Images/family_landing.png'),
            height: 300,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Family Access: Share Care with Loved Ones',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Invite family to manage your meds, updates, and care, all in one place.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

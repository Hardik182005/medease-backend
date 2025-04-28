import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 30),
        Center(
          child: Image(
            image: AssetImage('assets/Images/doc.png'),
            height: 300,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Secure Your Medical Records with DigiVault!',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'DigiVault keeps your prescriptions, reports, and health records safe and accessible.',
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

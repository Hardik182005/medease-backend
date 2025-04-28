import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medeasee/screens/full_register_screen.dart';
import 'package:medeasee/services/phone_auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = '';
  bool isButtonEnabled = false;
  int timer = 59;
  String? verificationId;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Do NOT resend OTP if verificationId already passed in
    // _sendOtp();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && timer > 0) {
        setState(() => timer--);
        _startTimer();
      }
    });
  }

  void _sendOtp() {
    PhoneAuthService.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (id, resendToken) {
        setState(() {
          verificationId = id;
        });
      },
      onVerificationCompleted: (credential) async {
        await PhoneAuthService.signInWithCredential(credential);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FullRegisterScreen()),
          );
        }
      },
      onVerificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification failed')),
        );
      },
      onAutoRetrievalTimeout: (id) {
        verificationId = id;
      },
    );
  }

  Future<void> _verifyOtp() async {
    final id = verificationId ?? widget.verificationId;
    if (id.isEmpty) return;

    final credential = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: otpCode,
    );

    try {
      await PhoneAuthService.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FullRegisterScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E47FF)),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send OTP Code',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit that we have sent via the phone number to ${widget.phoneNumber}',
                style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
              ),
              const SizedBox(height: 28),

              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                onChanged: (value) {
                  setState(() {
                    otpCode = value;
                    isButtonEnabled = value.length == 6;
                  });
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Color(0xFF1E47FF)),
                  const SizedBox(width: 8),
                  Text(
                    '00:${timer.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: timer == 0
                      ? () {
                    _otpController.clear();
                    setState(() {
                      otpCode = '';
                      isButtonEnabled = false;
                      timer = 59;
                    });
                    _startTimer();
                    _sendOtp();
                  }
                      : null,
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: Color(0xFF1E47FF),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: isButtonEnabled ? _verifyOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E47FF),
                  disabledBackgroundColor: Colors.grey.shade400,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'By signing up or logging in, I accept the apps',
                  style: TextStyle(fontSize: 12, fontFamily: 'Manrope'),
                ),
              ),
              const Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Color(0xFF1E47FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(text: ' and ', style: TextStyle(color: Colors.black)),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

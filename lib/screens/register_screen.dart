import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/phone_auth_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';
  bool isLoading = false;

  bool get isButtonEnabled => _phoneController.text.trim().length == 10;

  final List<String> countryCodes = ['+91', '+1', '+44', '+61', '+81', '+971'];

  void _sendOtp() async {
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';

    setState(() => isLoading = true);

    await PhoneAuthService.verifyPhoneNumber(
      phoneNumber: phone,
      onVerificationCompleted: (PhoneAuthCredential credential) {
        // Auto verification handler (you can sign in directly if desired)
      },
      onVerificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification failed')),
        );
      },
      onCodeSent: (String verificationId, int? resendToken) {
        setState(() => isLoading = false);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phoneNumber: phone,
                verificationId: verificationId,
              ),
            ),
          );
        }
      },
      onAutoRetrievalTimeout: (String verificationId) {
        setState(() => isLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0.5,
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
                'Register',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your number to continue your registration.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Phone Number',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedCountryCode,
                      underline: const SizedBox(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: countryCodes
                          .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCountryCode = value);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontFamily: 'Manrope', fontSize: 16),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: 'e.g 8128256234',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: isButtonEnabled && !isLoading ? _sendOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E47FF),
                  disabledBackgroundColor: Colors.grey.shade400,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'By signing up or logging in, I accept the apps',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: Colors.black87),
                ),
              ),
              const Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E47FF),
                    ),
                    children: [
                      TextSpan(text: ' and ', style: TextStyle(color: Colors.black)),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E47FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medeasee/screens/welcome_screen.dart';

class FullRegisterScreen extends StatefulWidget {
  const FullRegisterScreen({super.key});

  @override
  State<FullRegisterScreen> createState() => _FullRegisterScreenState();
}

class _FullRegisterScreenState extends State<FullRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _selectedGender = 'Male';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double passwordStrength = 0;

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 1;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 1;
    setState(() {
      passwordStrength = strength / 4;
    });
  }

  Color get strengthColor {
    if (passwordStrength <= 0.25) return Colors.red;
    if (passwordStrength <= 0.5) return Colors.orange;
    if (passwordStrength <= 0.75) return Colors.amber;
    return Colors.green;
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final fullName = _fullNameController.text.trim();
          final nameParts = fullName.split(' ');

          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'firstName': nameParts.isNotEmpty ? nameParts.first : '',
            'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            'email': _emailController.text.trim(),
            'age': _ageController.text.trim(),
            'gender': _selectedGender,
            'dob': '', // You can collect DOB later
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      } catch (e) {
        debugPrint('❌ Firestore Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please enter the details to register',
                  style: TextStyle(fontSize: 14, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 24),
                _buildTextField('Full Name', 'Enter your full name', _fullNameController),
                const SizedBox(height: 16),
                _buildTextField('Email', 'Enter your Email', _emailController, inputType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                const Text('Gender', style: TextStyle(fontSize: 14, fontFamily: 'Manrope')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value!),
                  decoration: _inputDecoration('Select gender'),
                ),
                const SizedBox(height: 16),
                _buildTextField('Age', 'Enter your Age', _ageController, inputType: TextInputType.number),
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(fontSize: 14, fontFamily: 'Manrope')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: _checkPasswordStrength,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter password' : null,
                  decoration: _inputDecoration('Enter your password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  passwordStrength == 1 ? 'Strong' : 'Weak',
                  style: TextStyle(
                    fontSize: 12,
                    color: strengthColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                  ),
                ),
                LinearProgressIndicator(
                  value: passwordStrength,
                  backgroundColor: Colors.grey.shade300,
                  color: strengthColor,
                  minHeight: 6,
                ),
                const SizedBox(height: 16),
                const Text('Confirm password', style: TextStyle(fontSize: 14, fontFamily: 'Manrope')),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: _inputDecoration('Confirm your password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E47FF),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'I have an account? Sign in',
                      style: TextStyle(
                        color: Color(0xFF1E47FF),
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontFamily: 'Manrope')),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Manrope'),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }
}

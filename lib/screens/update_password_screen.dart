import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isValid = false;

  void _validate() {
    final password = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    setState(() {
      _isValid = password.length >= 8 &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r'[a-zA-Z]').hasMatch(password) &&
          password == confirm;
    });
  }

  Future<void> _updatePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validate);
    _confirmPasswordController.addListener(_validate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Your Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: 'Your Current Password'),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'Your New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            _buildPasswordRules(),
            const Spacer(),
            ElevatedButton(
              onPressed: _isValid ? _updatePassword : null,
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRules() {
    final password = _newPasswordController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rule(password.length >= 8, 'Minimum 8 characters'),
        _rule(RegExp(r'[0-9]').hasMatch(password), 'At least 1 number (1–9)'),
        _rule(RegExp(r'[a-zA-Z]').hasMatch(password), 'At least one letter'),
      ],
    );
  }

  Widget _rule(bool passed, String text) {
    return Row(
      children: [
        Icon(passed ? Icons.check : Icons.close, color: passed ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

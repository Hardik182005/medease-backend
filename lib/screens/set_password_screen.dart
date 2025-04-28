import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isValid = false;

  void _validate() {
    final password = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    final isValid = password.length >= 8 &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[a-zA-Z]').hasMatch(password) &&
        password == confirm;
    setState(() => _isValid = isValid);
  }

  Future<void> _setPassword() async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(title: const Text('Set Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'Your New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            _buildPasswordRules(),
            const Spacer(),
            ElevatedButton(
              onPressed: _isValid ? _setPassword : null,
              child: const Text('Set Password'),
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

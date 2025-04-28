import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isPinSet = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkIfPinIsSet();
    _authenticateWithBiometrics();
  }

  Future<void> _checkIfPinIsSet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPinSet = prefs.containsKey('user_pin');
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();

    if (canCheck) {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to unlock the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        setState(() => _isAuthenticated = true);
      }
    }
  }

  Future<void> _setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
    setState(() {
      _isPinSet = true;
    });
    _showSuccess();
  }

  Future<void> _verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin');

    if (savedPin == enteredPin) {
      _showSuccess();
    } else {
      _showError("Incorrect PIN. Try again.");
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("App unlocked."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final enteredPin = _pinController.text.trim();
    if (enteredPin.length != 4) {
      _showError("PIN must be 4 digits.");
      return;
    }

    _isPinSet ? _verifyPin(enteredPin) : _setPin(enteredPin);
  }

  @override
  Widget build(BuildContext context) {
    if (_isPinSet && _isAuthenticated) {
      return const Scaffold(
        body: Center(child: Text("🔓 Unlocked with biometrics")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isPinSet ? 'Enter PIN' : 'Set PIN'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Use fingerprint or enter PIN", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: '4-digit PIN',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E47FF),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(_isPinSet ? 'Unlock' : 'Set PIN'),
            ),
          ],
        ),
      ),
    );
  }
}

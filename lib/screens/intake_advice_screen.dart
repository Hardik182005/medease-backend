import 'package:flutter/material.dart';

class IntakeAdviceScreen extends StatefulWidget {
  const IntakeAdviceScreen({super.key});

  @override
  State<IntakeAdviceScreen> createState() => _IntakeAdviceScreenState();
}

class _IntakeAdviceScreenState extends State<IntakeAdviceScreen> {
  final TextEditingController _adviceController = TextEditingController();

  @override
  void dispose() {
    _adviceController.dispose();
    super.dispose();
  }

  void _saveAdvice() {
    final advice = _adviceController.text.trim();

    if (advice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Advice can't be empty.")),
      );
      return;
    }

    // TODO: 🔗 Save advice to Firebase or pass back to previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Intake Advice",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Provide advice or notes related to medication intake:",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adviceController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "E.g. Take with a full glass of water...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E47FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E47FF), width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 15, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAdvice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E47FF),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save Advice",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

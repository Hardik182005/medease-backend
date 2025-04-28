import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'medication_frequency_screen.dart';

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({Key? key}) : super(key: key);

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _units = ['pill(s)', 'syrup', 'injection', 'Medicated Creams', 'Nasal Spray', 'Ear Drops'];
  String? _selectedUnit = 'pill(s)';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _goToNextScreen() {
    if (_formKey.currentState?.validate() ?? false) {
      final reminder = ReminderModel(
        medicineName: _nameController.text.trim(),
        unit: _selectedUnit!,
        frequency: '', // This will be updated in the next screen
      );

      debugPrint("➡️ Proceeding with Reminder: ${reminder.toMap()}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationFrequencyScreen(reminder: reminder),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/Images/reminder-2.png',
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Which medication would you like to set the reminder for?',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please enter medicine name'
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Medication Name',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        items: _units.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Select Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUnit = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E47FF),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

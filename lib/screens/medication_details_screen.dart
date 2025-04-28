import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final ReminderModel reminder;

  const MedicationDetailsScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final String name = reminder.medicineName;
    final String unit = reminder.unit;
    final String freq = reminder.frequency;

    final String timeStr = (reminder.times != null && reminder.times!.isNotEmpty)
        ? reminder.times!.join(", ")
        : "N/A";

    final String doseStr = (reminder.dose != null) ? "${reminder.dose} $unit" : "N/A";

    final String instructionsStr = (reminder.instructions != null && reminder.instructions!.isNotEmpty)
        ? reminder.instructions!.join(", ")
        : "No instructions";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Medication Details",
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
            Text(
              "💊 $name",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 24),

            _buildDetailRow("Frequency", freq),
            _buildDetailRow("Time(s)", timeStr),
            _buildDetailRow("Dose", doseStr),
            _buildDetailRow("Instructions", instructionsStr),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/intake-advice');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E47FF),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Add Intake Advice",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              fontFamily: 'Manrope',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontFamily: 'Manrope'),
            ),
          ),
        ],
      ),
    );
  }
}

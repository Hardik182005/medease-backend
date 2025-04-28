import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class TreatmentDurationScreen extends StatefulWidget {
  final ReminderModel reminder;

  const TreatmentDurationScreen({super.key, required this.reminder});

  @override
  State<TreatmentDurationScreen> createState() => _TreatmentDurationScreenState();
}

class _TreatmentDurationScreenState extends State<TreatmentDurationScreen> {
  bool _setDuration = true;
  String? _selectedDuration;
  DateTime? _selectedDate;
  bool _isSaving = false;

  final List<String> _durationOptions = List.generate(
    30,
        (i) => "${i + 1} ${i + 1 == 1 ? "day" : "days"}",
  );

  Future<void> _selectEndDate() async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (_setDuration && _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a treatment duration.")),
      );
      return;
    }

    final times = widget.reminder.times.isEmpty ? ['08:00 AM'] : widget.reminder.times;

    setState(() => _isSaving = true);

    try {
      // 🔥 Get FCM Token dynamically
      final fcmToken = await NotificationService.getToken();

      // ✅ Update reminder
      final updatedReminder = widget.reminder.copyWith(
        treatmentDuration: _setDuration ? _selectedDuration : null,
        treatmentEndDate: _selectedDate,
        times: times,
        fcmToken: fcmToken,
      );

      // ✅ Save to Firestore
      final docId = await ReminderService.saveReminder(updatedReminder);

      // ✅ Parse first time
      final firstTime = times.first;
      final parts = firstTime.split(RegExp(r"[:\\s]"));
      int hour = int.tryParse(parts[0]) ?? 8;
      int minute = int.tryParse(parts[1]) ?? 0;
      final isPM = parts.length > 2 && parts[2].toUpperCase() == 'PM';
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      // ✅ Schedule local notification
      await NotificationService.scheduleReminderWithAutoMiss(
        docId: docId,
        medicineName: updatedReminder.medicineName,
        unit: updatedReminder.unit,
        dose: updatedReminder.dose,
        hour: hour,
        minute: minute,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Reminder saved successfully!")),
      );

      Navigator.pushNamed(context, '/medication-overview');
    } catch (e) {
      debugPrint('❌ Error saving reminder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving reminder: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/Images/once_daily.png', height: 200, fit: BoxFit.cover),
            const SizedBox(height: 24),
            const Text(
              'Set your Treatment duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Set Duration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const Spacer(),
                Switch(
                  value: _setDuration,
                  activeColor: const Color(0xFF1E47FF),
                  onChanged: (val) => setState(() => _setDuration = val),
                ),
              ],
            ),
            if (_setDuration) ...[
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                hint: const Text("Select duration"),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: _durationOptions.map((duration) {
                  return DropdownMenuItem(value: duration, child: Text(duration));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDuration = val;
                    final days = int.tryParse(val?.split(" ").first ?? '') ?? 0;
                    _selectedDate = DateTime.now().add(Duration(days: days));
                  });
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectEndDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF1E47FF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat.yMMMd().format(_selectedDate!)
                            : 'Pick a date',
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 20),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E47FF),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Reminder', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

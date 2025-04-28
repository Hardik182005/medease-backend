import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'inventory_reminder_screen.dart';

class OnceDailyReminderScreen extends StatefulWidget {
  final ReminderModel reminder;

  const OnceDailyReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<OnceDailyReminderScreen> createState() => _OnceDailyReminderScreenState();
}

class _OnceDailyReminderScreenState extends State<OnceDailyReminderScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  int _dose = 0;
  String _selectedInstruction = 'After food';

  final List<String> _instructionOptions = ['Before food', 'After food', 'With food'];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _goToNext() {
    final updatedReminder = ReminderModel(
      medicineName: widget.reminder.medicineName,
      unit: widget.reminder.unit,
      frequency: widget.reminder.frequency,
      times: [_selectedTime.format(context)],
      dose: _dose,
      instructions: [_selectedInstruction],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryReminderScreen(reminder: updatedReminder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Image.asset('assets/Images/once_daily.png', height: 180),
                    const SizedBox(height: 24),
                    const Text(
                      'When would you like to be reminded?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    // Time
                    _buildTimePicker(),
                    const SizedBox(height: 20),
                    _buildDoseCounter(),
                    const SizedBox(height: 20),
                    _buildInstructionDropdown(),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _goToNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E47FF),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        const Text('Time', style: TextStyle(fontSize: 16)),
        const Spacer(),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(_selectedTime.format(context)),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoseCounter() {
    return Row(
      children: [
        const Text('Dose', style: TextStyle(fontSize: 16)),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setState(() => _dose = (_dose > 0) ? _dose - 1 : 0),
              ),
              Text('$_dose'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _dose++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionDropdown() {
    return Row(
      children: [
        const Text('Instructions', style: TextStyle(fontSize: 16)),
        const Spacer(),
        DropdownButton<String>(
          value: _selectedInstruction,
          underline: const SizedBox(),
          items: _instructionOptions.map((String option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedInstruction = value!);
          },
        ),
      ],
    );
  }
}

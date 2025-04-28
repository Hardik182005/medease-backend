import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'inventory_reminder_screen.dart';

class IntervalReminderScreen extends StatefulWidget {
  final ReminderModel reminder;

  const IntervalReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<IntervalReminderScreen> createState() => _IntervalReminderScreenState();
}

class _IntervalReminderScreenState extends State<IntervalReminderScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);

  int _dose = 0;
  String _selectedInstruction = 'After food';
  final List<String> _instructions = ['Before food', 'After food', 'With food'];

  String _selectedInterval = '6';
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(text: _selectedInterval);
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  List<TimeOfDay> _generateReminderTimes() {
    List<TimeOfDay> times = [];

    int intervalHours = int.tryParse(_selectedInterval.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    int startMinutes = _startTime.hour * 60 + _startTime.minute;
    int endMinutes = _endTime.hour * 60 + _endTime.minute;

    for (int minutes = startMinutes; minutes <= endMinutes; minutes += intervalHours * 60) {
      int hour = minutes ~/ 60;
      int minute = minutes % 60;
      times.add(TimeOfDay(hour: hour % 24, minute: minute));
    }

    return times;
  }

  void _goToNext() {
    final timesFormatted = _generateReminderTimes().map((t) => t.format(context)).toList();

    final updatedReminder = widget.reminder.copyWith(
      times: timesFormatted,
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
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/Images/reminder-2.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'When would you like to be reminded?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Start Time',
              child: GestureDetector(
                onTap: _selectStartTime,
                child: _timePickerBox(_startTime.format(context)),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'End Time',
              child: GestureDetector(
                onTap: _selectEndTime,
                child: _timePickerBox(_endTime.format(context)),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Interval',
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration().copyWith(
                        hintText: 'Enter hours',
                        suffixText: 'hr',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedInterval = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onSelected: (value) {
                      _intervalController.text = value.toString();
                      setState(() {
                        _selectedInterval = value.toString();
                      });
                    },
                    itemBuilder: (context) => [1, 2, 3, 4, 6, 8, 12]
                        .map((e) => PopupMenuItem<int>(
                      value: e,
                      child: Text('$e hr'),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Dose',
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => _dose = (_dose > 0) ? _dose - 1 : 0),
                  ),
                  Text('$_dose', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _dose++),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Instructions',
              child: DropdownButtonFormField<String>(
                value: _selectedInstruction,
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: _inputDecoration(),
                items: _instructions.map((instruction) {
                  return DropdownMenuItem<String>(
                    value: instruction,
                    child: Text(instruction),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInstruction = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToNext,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelAndField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            )),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _timePickerBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1E47FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1E47FF), width: 2),
      ),
    );
  }
}

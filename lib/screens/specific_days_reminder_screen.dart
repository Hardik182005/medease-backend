import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reminder_model.dart';
import 'inventory_reminder_screen.dart';

class SpecificDaysReminderScreen extends StatefulWidget {
  final ReminderModel reminder;

  const SpecificDaysReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<SpecificDaysReminderScreen> createState() => _SpecificDaysReminderScreenState();
}

class _SpecificDaysReminderScreenState extends State<SpecificDaysReminderScreen> {
  late VideoPlayerController _videoController;

  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};

  List<Map<String, dynamic>> _intakeList = [
    {'time': const TimeOfDay(hour: 8, minute: 0), 'dose': 0},
  ];

  String _selectedInstruction = 'After food';
  final List<String> _instructions = ['Before food', 'After food', 'With food'];

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/specific_times.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _intakeList[index]['time'],
    );
    if (picked != null) {
      setState(() {
        _intakeList[index]['time'] = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) => time.format(context);

  void _goToNext() {
    final times = _intakeList.map((e) => _formatTime(e['time'])).toList();
    final instructions = List.filled(times.length, _selectedInstruction);

    final updatedReminder = widget.reminder.copyWith(
      times: times,
      dose: _intakeList.fold<int>(0, (sum, e) => sum + (e['dose'] as int)),
      instructions: instructions,
      daysOfWeek: _selectedDays.toList(), // ✅ Fixed parameter
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
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_videoController.value.isInitialized)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
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
            const SizedBox(height: 4),
            const Text(
              'Choose days of the week for intake',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),

            /// Day Selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekdays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      isSelected ? _selectedDays.remove(day) : _selectedDays.add(day);
                    });
                  },
                  selectedColor: const Color(0xFF1E47FF),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            /// Time & Dose
            Column(
              children: _intakeList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectTime(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatTime(item['time']), style: const TextStyle(fontSize: 16)),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                if (item['dose'] > 0) item['dose']--;
                              });
                            },
                          ),
                          Text('${item['dose']}', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                item['dose']++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            /// Add Another Time
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _intakeList.add({
                    'time': const TimeOfDay(hour: 8, minute: 0),
                    'dose': 0,
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add another time',
                style: TextStyle(color: Color(0xFF1E47FF), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            /// Instructions
            const Text(
              'Instructions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedInstruction,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E47FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E47FF), width: 2),
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down),
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
            const SizedBox(height: 32),

            /// ✅ NEXT BUTTON
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
}

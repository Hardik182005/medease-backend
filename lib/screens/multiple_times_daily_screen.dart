import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reminder_model.dart';
import 'inventory_reminder_screen.dart';

class MultipleTimesDailyScreen extends StatefulWidget {
  final ReminderModel reminder;

  const MultipleTimesDailyScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<MultipleTimesDailyScreen> createState() => _MultipleTimesDailyScreenState();
}

class _MultipleTimesDailyScreenState extends State<MultipleTimesDailyScreen> {
  late VideoPlayerController _videoController;
  List<Map<String, dynamic>> reminderTimes = [];

  String _selectedInstruction = 'After food';
  final List<String> _instructions = ['Before food', 'After food', 'With food'];

  @override
  void initState() {
    super.initState();
    reminderTimes = [
      {"time": const TimeOfDay(hour: 6, minute: 0), "dose": 0},
      {"time": const TimeOfDay(hour: 14, minute: 0), "dose": 0},
    ];

    _videoController = VideoPlayerController.asset('assets/videos/multiple_times.mp4')
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
      initialTime: reminderTimes[index]['time'],
    );
    if (picked != null) {
      setState(() {
        reminderTimes[index]['time'] = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) => time.format(context);

  void _goToNext() {
    final times = reminderTimes.map((e) => _formatTime(e['time'])).toList();
    final instructions = List.filled(reminderTimes.length, _selectedInstruction);
    final totalDose = reminderTimes.fold<int>(0, (sum, e) => sum + (e['dose'] as int));

    final updatedReminder = widget.reminder.copyWith(
      times: times,
      dose: totalDose,
      instructions: instructions,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryReminderScreen(reminder: updatedReminder),
      ),
    );
  }

  Widget _buildStyledVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: _videoController.value.isInitialized
            ? FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: _videoController.value.size.width,
            height: _videoController.value.size.height,
            child: VideoPlayer(_videoController),
          ),
        )
            : const Center(child: CircularProgressIndicator()),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStyledVideo(),
            const SizedBox(height: 24),
            const Text(
              'When would you like to be reminded?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 16),

            /// Reminder Time List
            Column(
              children: reminderTimes.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
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
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            /// Add another reminder
            TextButton.icon(
              onPressed: () {
                setState(() {
                  reminderTimes.add({"time": const TimeOfDay(hour: 8, minute: 0), "dose": 0});
                });
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Add another time",
                style: TextStyle(color: Color(0xFF1E47FF), fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Instructions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 8),

            /// Instructions Dropdown
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
              onChanged: (value) => setState(() => _selectedInstruction = value!),
            ),
            const SizedBox(height: 24),

            /// ✅ NEXT Button with Navigation
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

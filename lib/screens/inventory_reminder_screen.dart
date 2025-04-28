import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reminder_model.dart';
import 'treatment_duration_screen.dart';

class InventoryReminderScreen extends StatefulWidget {
  final ReminderModel reminder;

  const InventoryReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<InventoryReminderScreen> createState() => _InventoryReminderScreenState();
}

class _InventoryReminderScreenState extends State<InventoryReminderScreen> {
  late VideoPlayerController _videoController;
  bool _remindMe = true;
  String? _selectedDay;
  bool _isSaving = false;

  final List<String> _days = ['Today', 'Tomorrow', 'In 3 days', 'Next week'];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.reminder.refillReminderDay;

    _videoController = VideoPlayerController.asset('assets/videos/inventory_reminder.mp4')
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

  Widget _buildVideoOrImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 220,
        color: Colors.black12,
        child: _videoController.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        )
            : Image.asset(
          'assets/Images/once_daily.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _selectCustomDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E47FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDay = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void _goToNext() {
    final updatedReminder = widget.reminder.copyWith(
      remindInventory: _remindMe,
      refillReminderDay: _remindMe ? _selectedDay : null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TreatmentDurationScreen(reminder: updatedReminder),
      ),
    );
  }

  void _goBackWithReminder() {
    final updatedReminder = widget.reminder.copyWith(
      remindInventory: _remindMe,
      refillReminderDay: _remindMe ? _selectedDay : null,
    );
    Navigator.pop(context, updatedReminder); // ✅ Return to previous screen with updated data
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackWithReminder();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackWithReminder,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoOrImage(),
                const SizedBox(height: 24),
                const Text(
                  'Do you want to get reminders to refill your inventory?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Remind me',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _remindMe,
                      activeColor: const Color(0xFF1E47FF),
                      onChanged: (val) {
                        setState(() => _remindMe = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_remindMe) ...[
                  const Text(
                    'Remind me when:',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _days.contains(_selectedDay) ? _selectedDay : null,
                    hint: const Text("Select day"),
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1E47FF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1E47FF), width: 2),
                      ),
                    ),
                    items: _days.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDay = val),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _selectCustomDate,
                      icon: const Icon(Icons.calendar_today,
                          color: Color(0xFF1E47FF), size: 18),
                      label: const Text(
                        "Pick a custom date",
                        style: TextStyle(
                            color: Color(0xFF1E47FF),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (_selectedDay != null && !_days.contains(_selectedDay)) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Selected: $_selectedDay",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E47FF),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

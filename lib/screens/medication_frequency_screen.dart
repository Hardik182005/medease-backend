import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/reminder_model.dart';
import 'once_daily_reminder_screen.dart';
import 'twice_daily_reminder_screen.dart';
import 'more_options_reminder_screen.dart';
import 'inventory_reminder_screen.dart';

class MedicationFrequencyScreen extends StatefulWidget {
  final ReminderModel reminder;

  const MedicationFrequencyScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<MedicationFrequencyScreen> createState() => _MedicationFrequencyScreenState();
}

class _MedicationFrequencyScreenState extends State<MedicationFrequencyScreen> {
  late VideoPlayerController _videoController;
  late String _selectedFrequency;

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'On Demand',
    'I need more options',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.reminder.frequency ?? 'Once daily';

    _videoController = VideoPlayerController.asset('assets/videos/reminder-3.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final updatedReminder = widget.reminder.copyWith(frequency: _selectedFrequency);

    if (_selectedFrequency == 'Once daily') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OnceDailyReminderScreen(reminder: updatedReminder),
        ),
      );
    } else if (_selectedFrequency == 'Twice daily') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TwiceDailyReminderScreen(reminder: updatedReminder),
        ),
      );
    } else if (_selectedFrequency == 'On Demand') {
      final result = await Navigator.push<ReminderModel>(
        context,
        MaterialPageRoute(
          builder: (_) => InventoryReminderScreen(reminder: updatedReminder),
        ),
      );

      // 👇 Restore updated reminder if user came back
      if (result != null) {
        setState(() {
          _selectedFrequency = result.frequency ?? 'On Demand';
        });
      }
    } else if (_selectedFrequency == 'I need more options') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoreOptionsReminderScreen(reminder: updatedReminder),
        ),
      );
    }
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
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _videoController.value.isInitialized
                            ? SizedBox(
                          height: 220,
                          child: AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: VideoPlayer(_videoController),
                          ),
                        )
                            : const SizedBox(height: 180),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'How often do you take this medication?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._frequencies.map(
                            (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFrequency = option;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedFrequency == option
                                      ? const Color(0xFF1E47FF)
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade100,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedFrequency == option
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: _selectedFrequency == option
                                        ? const Color(0xFF1E47FF)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNext,
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
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

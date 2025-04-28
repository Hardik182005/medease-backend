import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import 'interval_reminder_screen.dart';
import 'multiple_times_daily_screen.dart';
import 'specific_days_reminder_screen.dart';
import 'cyclic_mode_screen.dart';

class MoreOptionsReminderScreen extends StatefulWidget {
  final ReminderModel reminder;

  const MoreOptionsReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<MoreOptionsReminderScreen> createState() => _MoreOptionsReminderScreenState();
}

class _MoreOptionsReminderScreenState extends State<MoreOptionsReminderScreen> {
  String? _selectedOption;

  final List<Map<String, String>> _options = [
    {
      'title': 'Interval',
      'subtitle': 'e.g. once every 6 hours, once every second day',
    },
    {
      'title': 'Multiple times daily',
      'subtitle': 'e.g. 3 or more times a day',
    },
    {
      'title': 'Specific days of the week',
      'subtitle': 'e.g. Mon, Wed, Fri',
    },
    {
      'title': 'Cyclic mode',
      'subtitle': 'e.g. 21 days intake, 7 days pause',
    },
  ];

  void _handleNextNavigation() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option.')),
      );
      return;
    }

    final reminder = widget.reminder.copyWith(frequency: _selectedOption);

    switch (_selectedOption) {
      case 'Interval':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IntervalReminderScreen(reminder: reminder),
          ),
        );
        break;
      case 'Multiple times daily':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultipleTimesDailyScreen(reminder: reminder),
          ),
        );
        break;
      case 'Specific days of the week':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpecificDaysReminderScreen(reminder: reminder),
          ),
        );
        break;
      case 'Cyclic mode':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CyclicModeScreen(reminder: reminder),
          ),
        );
        break;
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Which of these options works for your medication schedule?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 24),
              ..._options.map((option) {
                bool isSelected = _selectedOption == option['title'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['subtitle']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Manrope',
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isSelected,
                          activeColor: const Color(0xFF1E47FF),
                          onChanged: (_) {
                            setState(() {
                              _selectedOption = option['title'];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNextNavigation,
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
      ),
    );
  }
}

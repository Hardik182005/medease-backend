import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reminder_model.dart';
import 'inventory_reminder_screen.dart';

class TwiceDailyReminderScreen extends StatefulWidget {
  final ReminderModel reminder;

  const TwiceDailyReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  State<TwiceDailyReminderScreen> createState() => _TwiceDailyReminderScreenState();
}

class _TwiceDailyReminderScreenState extends State<TwiceDailyReminderScreen> {
  late VideoPlayerController _videoController;

  TimeOfDay _firstTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _secondTime = const TimeOfDay(hour: 20, minute: 0);
  int _firstDose = 0;
  int _secondDose = 0;

  String _firstInstruction = 'After food';
  String _secondInstruction = 'After food';

  final List<String> _instructionOptions = [
    'Before food',
    'After food',
    'With food',
  ];

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/twice_daily.mp4')
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

  Future<void> _selectTime(BuildContext context, bool isFirst) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFirst ? _firstTime : _secondTime,
    );
    if (picked != null) {
      setState(() {
        if (isFirst) {
          _firstTime = picked;
        } else {
          _secondTime = picked;
        }
      });
    }
  }

  void _goToNext() {
    final updatedReminder = widget.reminder.copyWith(
      times: [
        _firstTime.format(context),
        _secondTime.format(context),
      ],
      dose: _firstDose + _secondDose,
      instructions: [_firstInstruction, _secondInstruction],
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

  Widget _buildTimeDoseInstructionBlock({
    required String label,
    required TimeOfDay time,
    required int dose,
    required String instruction,
    required bool isFirst,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Time', style: TextStyle(fontSize: 16)),
            const Spacer(),
            GestureDetector(
              onTap: () => _selectTime(context, isFirst),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(time.format(context)),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
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
                    onPressed: () {
                      setState(() {
                        if (isFirst && _firstDose > 0) _firstDose--;
                        if (!isFirst && _secondDose > 0) _secondDose--;
                      });
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text(isFirst ? '$_firstDose' : '$_secondDose'),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (isFirst) _firstDose++;
                        if (!isFirst) _secondDose++;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Instruction', style: TextStyle(fontSize: 16)),
            const Spacer(),
            DropdownButton<String>(
              value: isFirst ? _firstInstruction : _secondInstruction,
              underline: const SizedBox(),
              items: _instructionOptions.map((String option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  if (isFirst) {
                    _firstInstruction = value!;
                  } else {
                    _secondInstruction = value!;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildStyledVideo(),
              const SizedBox(height: 24),
              const Text(
                'When would you like to be reminded?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildTimeDoseInstructionBlock(
                      label: 'First intake',
                      time: _firstTime,
                      dose: _firstDose,
                      instruction: _firstInstruction,
                      isFirst: true,
                    ),
                    _buildTimeDoseInstructionBlock(
                      label: 'Second intake',
                      time: _secondTime,
                      dose: _secondDose,
                      instruction: _secondInstruction,
                      isFirst: false,
                    ),
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
}

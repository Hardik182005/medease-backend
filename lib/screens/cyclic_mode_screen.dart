import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import 'inventory_reminder_screen.dart';

class CyclicModeScreen extends StatefulWidget {
  final ReminderModel reminder;

  const CyclicModeScreen({super.key, required this.reminder});

  @override
  State<CyclicModeScreen> createState() => _CyclicModeScreenState();
}

class _CyclicModeScreenState extends State<CyclicModeScreen> {
  late VideoPlayerController _videoController;

  DateTime _startDate = DateTime.now();
  final TextEditingController _intakeController = TextEditingController(text: '21');
  final TextEditingController _pauseController = TextEditingController(text: '7');
  String _selectedInstruction = 'After food';

  final List<String> _instructions = ['Before food', 'After food', 'With food'];

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/cyclic_extension.mp4')
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
    _intakeController.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _goToNext() {
    final updatedReminder = widget.reminder.copyWith(
      times: [DateFormat.yMMMd().format(_startDate)],
      instructions: [_selectedInstruction],
      cycleIntakeDays: int.tryParse(_intakeController.text.trim()) ?? 0,
      cyclePauseDays: int.tryParse(_pauseController.text.trim()) ?? 0,
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_videoController.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            const SizedBox(height: 24),
            const Text(
              "What’s the first day of this medication cycle?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_intakeController.text} intake days, ${_pauseController.text} days pause',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 24),

            _buildLabelAndField(
              label: 'Start date',
              child: GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat.yMMMd().format(_startDate), style: const TextStyle(fontSize: 16)),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Intake days',
              child: TextField(
                controller: _intakeController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Pause days',
              child: TextField(
                controller: _pauseController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabelAndField(
              label: 'Instructions',
              child: DropdownButtonFormField<String>(
                value: _selectedInstruction,
                decoration: _inputDecoration(),
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
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
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
    );
  }
}

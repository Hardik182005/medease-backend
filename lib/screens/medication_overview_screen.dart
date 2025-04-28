import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import 'medication_details_screen.dart';

class MedicationOverviewScreen extends StatefulWidget {
  const MedicationOverviewScreen({super.key});

  @override
  State<MedicationOverviewScreen> createState() => _MedicationOverviewScreenState();
}

class _MedicationOverviewScreenState extends State<MedicationOverviewScreen> {
  int _selectedIndex = 0;
  List<ReminderModel> reminders = [];

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    final routes = ['/reminder', '/medvault', '/sos', '/family-access', '/account'];
    Navigator.pushNamed(context, routes[index]);
  }

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final result = await ReminderService.getReminders();
    setState(() => reminders = result);
  }

  Future<void> _handleAction(String docId, String action) async {
    await ReminderService.updateReminderStatus(docId, action);
    _loadReminders();
  }

  Widget _buildStatusChip(String? status) {
    final lower = status?.toLowerCase() ?? 'pending';
    Color color;
    String label;

    switch (lower) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed ✅';
        break;
      case 'skipped':
        color = Colors.red;
        label = 'Skipped ❌';
        break;
      default:
        color = Colors.orange;
        label = 'Pending ⏳';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi $userName!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 2),
            const Text('Never miss your dose again!', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.notifications_none))],
      ),
      body: reminders.isEmpty
          ? const Center(child: Text('No reminders yet.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          final timeText = reminder.times?.join(", ") ?? 'No time';
          final docId = reminder.id ?? ''; // 🔁 ID from model

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💊 ${reminder.medicineName}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("${reminder.frequency} — $timeText", style: const TextStyle(color: Colors.black54)),
                  _buildStatusChip(reminder.status),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => _handleAction(docId, 'confirmed'),
                        child: const Text("Confirm"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _handleAction(docId, 'skipped'),
                        child: const Text("Skip"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicationDetailsScreen(reminder: reminder),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E47FF),
                        ),
                        child: const Text("Details"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 2,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xFF1E47FF),
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(_selectedIndex == 0 ? 'assets/icons/reminder_selected.png' : 'assets/icons/reminder.png', height: 24),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(_selectedIndex == 1 ? 'assets/icons/medvault_selected.png' : 'assets/icons/medvault.png', height: 24),
            label: 'Medvault',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(_selectedIndex == 2 ? 'assets/icons/sos_selected.png' : 'assets/icons/sos.png', height: 24),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(_selectedIndex == 3 ? 'assets/icons/family_selected.png' : 'assets/icons/family.png', height: 24),
            label: 'Family Access',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(_selectedIndex == 4 ? 'assets/icons/account_selected.png' : 'assets/icons/account.png', height: 24),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

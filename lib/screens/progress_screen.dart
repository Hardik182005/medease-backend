import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Map<String, String>> medicineProgress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchProgress();
  }

  List<DateTime> getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
  }

  Future<void> fetchProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final remindersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .get();

    final data = <String, Map<String, String>>{};

    for (final reminder in remindersSnapshot.docs) {
      final reminderId = reminder.id;
      final reminderData = reminder.data();
      final medicine = reminderData['medicineName'] ?? 'Unknown';

      final progressSnapshot = await reminder.reference.collection('progress').get();
      for (final doc in progressSnapshot.docs) {
        final progress = doc.data();
        final date = progress['date'];
        final status = progress['status'];
        if (date == null || status == null) continue;

        data.putIfAbsent(medicine, () => {});
        data[medicine]![date] = status;
      }
    }

    setState(() => medicineProgress = data);
  }

  Widget buildChartView() {
    final days = getLast7Days();
    final shortDate = DateFormat('yyyy-MM-dd');
    final shortDay = DateFormat.E(); // Mon, Tue, etc.

    return ListView(
      padding: const EdgeInsets.all(16),
      children: medicineProgress.entries.map((entry) {
        final medicine = entry.key;
        final statusMap = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicine,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: days.map((day) {
                final dayStr = shortDate.format(day);
                final status = statusMap[dayStr];

                Icon icon;
                if (status == 'confirmed') {
                  icon = const Icon(Icons.check_circle, color: Colors.green);
                } else if (status == 'missed') {
                  icon = const Icon(Icons.cancel, color: Colors.red);
                } else if (status == 'skipped') {
                  icon = const Icon(Icons.remove_circle, color: Colors.orange);
                } else {
                  icon = const Icon(Icons.radio_button_unchecked, color: Colors.grey);
                }

                return Expanded(
                  child: Column(
                    children: [
                      Text(shortDay.format(day), style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      icon,
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget buildListView() {
    final sortedItems = <Map<String, dynamic>>[];

    medicineProgress.forEach((medicine, progressMap) {
      progressMap.forEach((date, status) {
        sortedItems.add({'medicine': medicine, 'date': date, 'status': status});
      });
    });

    sortedItems.sort((a, b) => b['date'].compareTo(a['date']));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        final date = DateTime.tryParse(item['date']) ?? DateTime.now();
        final status = item['status'];
        final medicine = item['medicine'];

        Icon icon;
        Color color;
        if (status == 'confirmed') {
          icon = const Icon(Icons.check, color: Colors.green);
          color = Colors.green;
        } else if (status == 'skipped') {
          icon = const Icon(Icons.remove_circle, color: Colors.orange);
          color = Colors.orange;
        } else if (status == 'missed') {
          icon = const Icon(Icons.cancel, color: Colors.red);
          color = Colors.red;
        } else {
          icon = const Icon(Icons.radio_button_unchecked, color: Colors.grey);
          color = Colors.grey;
        }

        return ListTile(
          leading: const Icon(Icons.medication_outlined),
          title: Text(medicine),
          subtitle: Text(DateFormat('EEEE, MMM d, y').format(date)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              icon,
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Progress"),
        backgroundColor: const Color(0xFF1E47FF),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "CHARTS"),
            Tab(text: "LIST"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildChartView(),
          buildListView(),
        ],
      ),
    );
  }
}

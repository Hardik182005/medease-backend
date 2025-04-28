import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io' show Platform;

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool isLargeAlert = true;
  bool recurring = true;
  bool hideNames = false;
  bool remindTill = false;
  String remindEvery = "5 min";

  final List<String> remindOptions = ['5 min', '10 min', '30 min', '1 hr'];

  void _openDeviceSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        arguments: <String, dynamic>{
          'android.provider.extra.APP_PACKAGE': 'com.example.medeasee',
        },
      );
      await intent.launch();
    } else {
      // For iOS, open device Settings (not app-specific)
      // Can use url_launcher with 'App-prefs:root=NOTIFICATIONS_ID'
      debugPrint('iOS: Open notification settings manually');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("Notification Settings", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Appearance",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildAlertTile("LARGE ALERT", isLargeAlert, () {
                  setState(() => isLargeAlert = true);
                }),
                const SizedBox(width: 16),
                _buildAlertTile("STANDARD", !isLargeAlert, () {
                  setState(() => isLargeAlert = false);
                }),
              ],
            ),
            const SizedBox(height: 20),
            _buildListTile(
              title: "Notification sound",
              trailing: const Text("Edit", style: TextStyle(color: Colors.blueAccent)),
              onTap: () {},
            ),
            const Divider(color: Colors.black12),
            SwitchListTile(
              title: const Text("Recurring reminder", style: TextStyle(color: Colors.black)),
              subtitle: const Text(
                "Keep reminding until you confirm or skip",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              value: recurring,
              activeColor: Colors.blueAccent,
              onChanged: (val) => setState(() => recurring = val),
            ),
            if (recurring) _buildDropdownTile("Remind every", remindEvery),
            const Divider(color: Colors.black12),
            SwitchListTile(
              title: const Text("Hide medication names", style: TextStyle(color: Colors.black)),
              subtitle: const Text(
                "For privacy, don't show treatment names",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              value: hideNames,
              activeColor: Colors.blueAccent,
              onChanged: (val) => setState(() => hideNames = val),
            ),
            SwitchListTile(
              title: const Text("Remind Till", style: TextStyle(color: Colors.black)),
              subtitle: const Text(
                "Keep reminding until task is done",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              value: remindTill,
              activeColor: Colors.blueAccent,
              onChanged: (val) => setState(() => remindTill = val),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _openDeviceSettings,
              child: const Text(
                "Go to device settings",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(String label, String currentValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          DropdownButton<String>(
            dropdownColor: Colors.white,
            value: currentValue,
            style: const TextStyle(color: Colors.black),
            underline: Container(),
            items: remindOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => remindEvery = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

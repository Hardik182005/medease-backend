import 'package:flutter/material.dart';

class SecurityAndDataScreen extends StatelessWidget {
  const SecurityAndDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Data'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Password & Lock',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            title: const Text('Update Your Password'),
            subtitle: const Text('Set a new Medilert password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/update-password'),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Set App Lock'),
            subtitle: const Text('Enable fingerprint or PIN lock'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/app-lock'),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Privacy',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            title: const Text('Manage Personal Info'),
            subtitle: const Text('View and edit your profile details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/personal-info'),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

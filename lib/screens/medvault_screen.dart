import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_documents_screen.dart';

class MedVaultScreen extends StatefulWidget {
  const MedVaultScreen({super.key});

  @override
  State<MedVaultScreen> createState() => _MedVaultScreenState();
}

class _MedVaultScreenState extends State<MedVaultScreen> {
  int _selectedIndex = 1;

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/reminder');
        break;
      case 1:
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚧 SOS feature coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 3:
        Navigator.pushNamed(context, '/family-access');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // ✅ Set to white
        selectedItemColor: const Color(0xFF1E47FF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0
                  ? 'assets/icons/reminder_selected.png'
                  : 'assets/icons/reminder.png',
              height: 24,
            ),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1
                  ? 'assets/icons/medvault_selected.png'
                  : 'assets/icons/medvault.png',
              height: 24,
            ),
            label: 'Medvault',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2
                  ? 'assets/icons/sos_selected.png'
                  : 'assets/icons/sos.png',
              height: 24,
            ),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 3
                  ? 'assets/icons/family_selected.png'
                  : 'assets/icons/family.png',
              height: 24,
            ),
            label: 'Family Access',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 4
                  ? 'assets/icons/account_selected.png'
                  : 'assets/icons/account.png',
              height: 24,
            ),
            label: 'Account',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $userName!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'MedVault - Your Health Records, Secured & Simplified',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCard(
                      context,
                      title: 'Prescription',
                      subtitle: 'Upload or View your Prescription',
                      imagePath: 'assets/Images/prescription_image.png',
                      backgroundColor: const Color(0xFFF2F1FD),
                      borderColor: const Color(0xFFD8D7FB),
                    ),
                    _buildCard(
                      context,
                      title: 'Test Records',
                      subtitle: 'Upload or View your Test Records',
                      imagePath: 'assets/Images/test_image.png',
                      backgroundColor: const Color(0xFFFFF9E9),
                      borderColor: const Color(0xFFFFECAA),
                    ),
                    _buildCard(
                      context,
                      title: 'Medical Bills',
                      subtitle: 'Upload or View your Medical Bills',
                      imagePath: 'assets/Images/bill_image.png',
                      backgroundColor: const Color(0xFFF1FFF3),
                      borderColor: const Color(0xFFBFFFD0),
                    ),
                    _buildCard(
                      context,
                      title: 'Health Records',
                      subtitle: 'View your Health Records',
                      imagePath: 'assets/Images/health_record.png',
                      backgroundColor: const Color(0xFFFFF1F1),
                      borderColor: const Color(0xFFFFD8D8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String imagePath,
        required String title,
        required String subtitle,
        required Color backgroundColor,
        required Color borderColor,
      }) {
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () {
        if (title == 'Health Records') {
          Navigator.pushNamed(
            context,
            '/view-documents',
            arguments: {
              'docType': title,
              'userId': user?.uid ?? '',
            },
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadDocumentsScreen(docType: title),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, height: 40, width: 40),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

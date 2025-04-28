import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedIndex = 4;

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/reminder');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/medvault');
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
        Navigator.pushReplacementNamed(context, '/family-access');
        break;
      case 4:
        break; // Already on Account
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Account & Settings',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(
              'Account Info',
              'Edit your personal info',
              'assets/icons/acc.png',
                  () => Navigator.pushNamed(context, '/account-info'),
            ),
            _buildCard(
              'Notifications',
              'Configure how your alerts are received',
              'assets/icons/notification.png',
                  () => Navigator.pushNamed(context, '/notification-settings'), // ✅ Updated
            ),
            _buildCard(
              'My Medicines',
              'Update medicines',
              'assets/icons/tablet.png',
                  () {
                // TODO: Add medicines screen if needed
              },
            ),
            _buildCard(
              'Security & Data',
              'Manage personal info',
              'assets/icons/data.png',
                  () => Navigator.pushNamed(context, '/security-data'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: const Color(0xFF1E47FF),
          unselectedItemColor: Colors.grey,
          onTap: _onTabTapped,
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
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(iconPath, height: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Manrope',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

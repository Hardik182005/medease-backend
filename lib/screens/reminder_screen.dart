import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medication_form_screen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
      // Already on Reminder screen
        break;
      case 1:
        Navigator.pushNamed(context, '/medvault');
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $userName!',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Never miss your dose again!',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Images/reminder-1.png',
              height: 200,
            ),
            const SizedBox(height: 24),
            const Text(
              'Never miss a dose again!\nSet reminders for your medications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Get Started',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicationFormScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E47FF),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add Reminder',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
}

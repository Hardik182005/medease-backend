import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

class CareBuddyProfileScreen extends StatefulWidget {
  const CareBuddyProfileScreen({super.key});

  @override
  State<CareBuddyProfileScreen> createState() => _CareBuddyProfileScreenState();
}

class _CareBuddyProfileScreenState extends State<CareBuddyProfileScreen> {
  int _selectedIndex = 3;
  late VideoPlayerController _videoController;

  List<Map<String, dynamic>> connections = [];
  String? selectedUserId;
  String? selectedUserName;
  List<Map<String, dynamic>> medications = [];

  bool _loadingConnections = true;
  bool _loadingMeds = false;

  @override
  void initState() {
    super.initState();
    _loadCareConnections();

    _videoController = VideoPlayerController.asset('assets/videos/carebuddy_profile.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  Future<void> _loadCareConnections() async {
    final carebuddyId = FirebaseAuth.instance.currentUser?.uid;
    if (carebuddyId == null) {
      print('❌ No CareBuddy logged in');
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carebuddy_users')
          .doc(carebuddyId)
          .collection('connections')
          .get();

      if (snapshot.docs.isNotEmpty) {
        connections = snapshot.docs
            .map((doc) => {
          'userId': doc.id,
          'name': doc.data()['name'] ?? 'User',
        })
            .toList();

        setState(() {
          selectedUserId = connections.first['userId'];
          selectedUserName = connections.first['name'];
          _loadingConnections = false;
        });

        _loadMedicationsOfUser(selectedUserId!);
      } else {
        setState(() => _loadingConnections = false);
      }
    } catch (e) {
      print('❌ Error loading connections: $e');
      setState(() => _loadingConnections = false);
    }
  }

  Future<void> _loadMedicationsOfUser(String userId) async {
    setState(() {
      _loadingMeds = true;
      medications = [];
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .get();

      setState(() {
        medications = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _loadingMeds = false;
      });
    } catch (e) {
      print('❌ Error loading medications for user $userId: $e');
      setState(() => _loadingMeds = false);
    }
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/reminder');
        break;
      case 1:
        Navigator.pushNamed(context, '/medvault');
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🚧 SOS feature coming soon!')),
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
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carebuddyName = FirebaseAuth.instance.currentUser?.displayName ?? 'CareBuddy';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              carebuddyName,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const Text(
              "You're viewing shared profiles",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/welcome');
            },
            child: const Text(
              'Return to My Profile',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
      body: _loadingConnections
          ? const Center(child: CircularProgressIndicator())
          : connections.isEmpty
          ? const Center(child: Text("No CareBuddy connections yet."))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _videoController.value.isInitialized
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            )
                : const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 20),
            const Text(
              "Choose a user to view meds",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedUserId,
              borderRadius: BorderRadius.circular(12),
              items: connections
                  .map((user) => DropdownMenuItem<String>(
                value: user['userId'] as String,
                child: Text(user['name'] ?? 'User'),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedUserId = val;
                  selectedUserName = connections
                      .firstWhere((c) => c['userId'] == val)['name'];
                });
                _loadMedicationsOfUser(val!);
              },
            ),
            const SizedBox(height: 20),
            Text(
              "$selectedUserName's Medications",
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _loadingMeds
                ? const Center(child: CircularProgressIndicator())
                : medications.isEmpty
                ? const Text("No medications found.")
                : Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final med = medications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.medical_services_outlined),
                      title: Text(med['medicineName'] ?? 'Unnamed'),
                      subtitle: Text(med['frequency'] ?? 'No frequency'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
        selectedItemColor: const Color(0xFF1E47FF),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

class FamilyAccessScreen extends StatefulWidget {
  const FamilyAccessScreen({Key? key}) : super(key: key);

  @override
  State<FamilyAccessScreen> createState() => _FamilyAccessScreenState();
}

class _FamilyAccessScreenState extends State<FamilyAccessScreen> {
  int _selectedIndex = 3;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/page_1.mp4')
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
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? 'XYZ';

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
              'CareBuddy – Your Family, Connected & Protected',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/invite-carebuddy');
                  },
                  child: _buildAccessCard(
                    title: "Invite",
                    subtitle: "Invite your Carebuddy",
                    imagePath: 'assets/Images/invite.png',
                    color: const Color(0xFFF5E9F4),
                    borderColor: const Color(0xFFD9B8D3),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/connect-carebuddy');
                  },
                  child: _buildAccessCard(
                    title: "Connect",
                    subtitle: "Connect with your\nCarebuddy Manually",
                    imagePath: 'assets/Images/connect.png',
                    color: const Color(0xFFFFFBE6),
                    borderColor: const Color(0xFFFFECB3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/share-link');
              },
              child: _buildAccessCard(
                title: "Share Link",
                subtitle: "Share link with your\nCarebuddy",
                imagePath: 'assets/Images/share.png',
                color: const Color(0xFFE8F4FF),
                borderColor: const Color(0xFFB3D6F7),
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAccessCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color color,
    required Color borderColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : (MediaQuery.of(context).size.width - 72) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

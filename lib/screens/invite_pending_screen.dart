import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/carebuddy_service.dart'; // ✅ ensure this file exists

class InvitePendingScreen extends StatefulWidget {
  const InvitePendingScreen({super.key});

  @override
  State<InvitePendingScreen> createState() => _InvitePendingScreenState();
}

class _InvitePendingScreenState extends State<InvitePendingScreen> {
  late VideoPlayerController _videoController;
  Map<String, dynamic>? _pendingInvite;
  String? _docId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingInvite();

    _videoController = VideoPlayerController.asset('assets/videos/invite_page.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  Future<void> _loadPendingInvite() async {
    final result = await CareBuddyService.getPendingInvite();

    setState(() {
      _pendingInvite = result?['data'];
      _docId = result?['docId'];
      _isLoading = false;
    });
  }

  Future<void> _deleteInvite() async {
    if (_docId == null) return;

    try {
      await CareBuddyService.deleteInvite(_docId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invite deleted.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting invite.")),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Invite CareBuddy (pending)',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _deleteInvite,
            icon: const Icon(Icons.delete_outline, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            if (_videoController.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              )
            else
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 20),
            const Text(
              'A CareBuddy is a trusted family member or friend who helps you manage your medications. '
                  'They can receive reminders and can track your doses',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 36),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Request Pending',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _pendingInvite?['name'] ?? 'No pending invite',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E47FF),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/reminder');
              break;
            case 1:
              Navigator.pushNamed(context, '/medvault');
              break;
            case 2:
              Navigator.pushNamed(context, '/sos');
              break;
            case 3:
              Navigator.pushNamed(context, '/family-access');
              break;
            case 4:
              Navigator.pushNamed(context, '/account');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/reminder.png', height: 24),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/medvault.png', height: 24),
            label: 'Medvault',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/sos.png', height: 24),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/family_selected.png', height: 24),
            label: 'Family Access',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/account.png', height: 24),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

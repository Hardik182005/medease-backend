import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/carebuddy_service.dart';

class InviteCareBuddyScreen extends StatefulWidget {
  const InviteCareBuddyScreen({Key? key}) : super(key: key);

  @override
  State<InviteCareBuddyScreen> createState() => _InviteCareBuddyScreenState();
}

class _InviteCareBuddyScreenState extends State<InviteCareBuddyScreen> {
  late VideoPlayerController _videoController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/invite_page.mp4')
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);
    print("Inviting CareBuddy at: $email");

    try {
      await CareBuddyService.inviteCareBuddy(
        carebuddyEmail: email,
        name: name,
        phone: phone,
      );

      _showSnackBar("Invitation Sent");
      Navigator.pushNamed(context, '/invite-carebuddy-pending');
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Invite CareBuddy',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          _isLoading
              ? const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : TextButton(
            onPressed: _handleSend,
            child: const Text(
              'Send',
              style: TextStyle(
                color: Color(0xFF1E47FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Manrope',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                  'A CareBuddy is a trusted family member or friend who helps you manage your medications.\nThey can receive reminders and can track your doses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  icon: 'assets/icons/contacts_fill.png',
                  hintText: 'Name',
                  controller: _nameController,
                  suffixIcon: 'assets/icons/account_pin.png',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  icon: 'assets/icons/phone_fill.png',
                  hintText: 'Phone Number',
                  controller: _phoneController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  icon: 'assets/icons/email_fill.png',
                  hintText: 'Email',
                  controller: _emailController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String icon,
    required String hintText,
    required TextEditingController controller,
    String? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 20, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          if (suffixIcon != null)
            Image.asset(suffixIcon, width: 20, height: 20),
        ],
      ),
    );
  }
}

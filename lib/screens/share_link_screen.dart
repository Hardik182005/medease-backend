import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/carebuddy_service.dart';

class ShareLinkScreen extends StatefulWidget {
  const ShareLinkScreen({Key? key}) : super(key: key);

  @override
  State<ShareLinkScreen> createState() => _ShareLinkScreenState();
}

class _ShareLinkScreenState extends State<ShareLinkScreen> {
  late VideoPlayerController _controller;

  String carebuddyName = '';
  String inviteLink = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInviteDetails();

    _controller = VideoPlayerController.asset('assets/videos/share_link.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  Future<void> _loadInviteDetails() async {
    try {
      final result = await CareBuddyService.getPendingInvite();

      if (result != null) {
        setState(() {
          carebuddyName = result['data']['name'] ?? 'CareBuddy';
          inviteLink = result['data']['inviteLink'] ?? '';
          _isLoading = false;
        });
      } else {
        _showSnackBar("No invite found");
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Error loading invite");
      Navigator.pop(context);
    }
  }

  Future<void> _shareInvite() async {
    if (inviteLink.isEmpty) {
      _showSnackBar("No link to share");
      return;
    }

    final message =
        "Hey $carebuddyName 👋\n\nI'd love for you to be my CareBuddy on MedEase!\nClick the link to connect and manage my meds together:\n\n$inviteLink";

    await Share.share(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          'Share Link',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Return',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: 'Manrope',
              ),
            ),
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
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayer(_controller),
              ),
            )
                : const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 32),
            Text(
              carebuddyName,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _shareInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E47FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Send Invitation',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

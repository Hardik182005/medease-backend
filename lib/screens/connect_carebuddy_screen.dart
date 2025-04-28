import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ConnectCareBuddyScreen extends StatefulWidget {
  const ConnectCareBuddyScreen({super.key});

  @override
  State<ConnectCareBuddyScreen> createState() => _ConnectCareBuddyScreenState();
}

class _ConnectCareBuddyScreenState extends State<ConnectCareBuddyScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/connect_manually.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });

    // Show "Coming Soon" popup with blur effect after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _showComingSoonDialog());
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _showComingSoonDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2), // Background dim
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Coming Soon 🚧',
                style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Manual connection with verification code will be available in the next update.',
                style: TextStyle(fontFamily: 'Manrope'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const carebuddyName = 'CareBuddy Name'; // Replace with dynamic name if needed
    const verificationCode = '6JT6'; // Replace with actual generated code

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          'Connect CareBuddy',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _videoController.value.isInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              )
                  : const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              carebuddyName,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 12),
            const Text(
              'To manually connect',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '''1. Download Medease from the App Store or Google Play.
2. Open the Medease app and log in.
3. Go to "Settings" by tapping the More menu (bottom right corner).
4. Select "Verification Code" under the CareBuddy section.
5. Enter the following code:''',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              verificationCode,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

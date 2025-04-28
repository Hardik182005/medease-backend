import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/logo_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();

        _videoController.addListener(() async {
          final isFinished = _videoController.value.position >= _videoController.value.duration;
          if (isFinished && mounted) {
            await _handleNavigation();
          }
        });
      });
  }

  Future<void> _handleNavigation() async {
    final user = FirebaseAuth.instance.currentUser;

    // Optional delay if video ends too quickly
    await Future.delayed(const Duration(milliseconds: 500));

    if (user == null) {
      // Not logged in → Login screen
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Logged in → check onboarding
      final prefs = await SharedPreferences.getInstance();
      final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

      if (onboardingSeen) {
        Navigator.pushReplacementNamed(context, '/reminder'); // 👈 main home screen
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
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
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _videoController.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              )
                  : const CircularProgressIndicator(),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Medease Mobile App',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C5B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

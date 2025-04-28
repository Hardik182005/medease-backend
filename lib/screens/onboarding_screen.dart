import 'package:flutter/material.dart';
import 'onboarding_screen_2.dart';
import 'onboarding_screen_3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> pages = const [
    _OnboardingPage1(),
    OnboardingScreen2(),
    OnboardingScreen3(),
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: pages[index]),

                        const SizedBox(height: 16),

                        // Dot Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                                (dotIndex) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              height: 8,
                              width: _currentPage == dotIndex ? 32 : 12,
                              decoration: BoxDecoration(
                                color: _currentPage == dotIndex
                                    ? const Color(0xFF1E47FF)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),

              // Buttons
              Row(
                children: [
                  if (_currentPage < pages.length - 1)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/landing');
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage < pages.length - 1)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1E47FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == pages.length - 1
                            ? 'Get Started !'
                            : 'Next',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 30),
        Center(
          child: Image(
            image: AssetImage('assets/Images/medicine 1.png'),
            height: 300,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Welcome To MedEase!',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'We help you stay on top of your health with timely medication reminders, emergency support, secure medical storage, and family access.',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Get started today!',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<OnboardingCard> cards = [
    OnboardingCard(
      icon: Icons.run_circle_outlined,
      title: 'Track Your Workouts',
      subtitle: 'Monitor your exercise routines and progress',
    ),
    OnboardingCard(
      icon: Icons.checklist,
      title: 'Set Fitness Goals',
      subtitle: 'Define your personal targets',
    ),
    OnboardingCard(
      icon: Icons.trending_up,
      title: 'View Activity Stats',
      subtitle: 'See your daily and weekly trends',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cards[index].icon,
                        size: 100,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        cards[index].title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        cards[index].subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Progress Dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                cards.length,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: _currentIndex < cards.length - 1
                      ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : _completeOnboarding,
                  child: Text(_currentIndex < cards.length - 1
                      ? 'Next'
                      : 'Get Started'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingCard {
  final IconData icon;
  final String title;
  final String subtitle;

  OnboardingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

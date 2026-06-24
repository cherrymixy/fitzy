import 'package:flutter/material.dart';

import '../data/onboarding_copy.dart';
import 'signup_screen.dart';

/// 온보딩 4스텝(회색박스). 마지막 "시작" → 가입.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < kOnboardingCopy.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == kOnboardingCopy.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: kOnboardingCopy.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  color: const Color(0xFFE0E0E0), // 회색박스
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}. ${kOnboardingCopy[i]}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                kOnboardingCopy.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? Colors.black54 : Colors.black26,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? '시작' : '다음'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

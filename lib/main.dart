import 'package:flutter/material.dart';

void main() {
  runApp(const FitzyApp());
}

/// STEP 1 스캐폴드: "FITZY" 한 줄만 노출하는 빈 셸.
/// 모델·로직·실제 화면·테마 토큰은 이후 단계에서 추가한다.
class FitzyApp extends StatelessWidget {
  const FitzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FITZY',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('FITZY'),
        ),
      ),
    );
  }
}

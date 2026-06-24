import 'package:flutter/material.dart';

/// 진입 후 임시 셸. STEP 7에서 4탭(Select/Board/Calendar/My)으로 대체.
class MainPlaceholder extends StatelessWidget {
  const MainPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('FITZY')),
    );
  }
}

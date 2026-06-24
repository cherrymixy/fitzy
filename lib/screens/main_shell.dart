import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/board_provider.dart';
import '../providers/coin_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/fitzy_header.dart';
import '../widgets/floating_nav.dart';
import 'board_screen.dart';
import 'calendar_screen.dart';
import 'my_screen.dart';
import 'select_screen.dart';

/// 로그인 후 공통 셸 (SSOT shell): 상단 좌측 로고 + 우측 코인 칩, 하단 떠 있는 네비.
/// 진입 시 코인 일일 지급(refreshDaily)·과거 보드 마감(finalizePastRecords).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      context.read<CoinProvider>().refreshDaily(now);
      context.read<BoardProvider>().finalizePastRecords(now);
    });
  }

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _index,
                children: [
                  SelectScreen(onDrawn: () => _select(1)),
                  const BoardScreen(),
                  const CalendarScreen(),
                  const MyScreen(),
                ],
              ),
            ),
            // 공통 헤더 (SSOT logo top 70 - 상태바 54 = 16)
            const Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: FitzyHeader(),
            ),
            // 떠 있는 네비 (SSOT bottom 33)
            Positioned(
              bottom: 33,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingNav(currentIndex: _index, onTap: _select),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

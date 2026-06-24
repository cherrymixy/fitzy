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

/// 로그인 후 공통 셸 (SSOT shell). 풀프레임 절대좌표(상태바/홈인디케이터 포함)로
/// 매핑 — SafeArea로 감싸지 않는다(감싸면 하단 인셋이 이중 계산돼 네비가 떠오름).
/// 헤더 top 70 / 네비 bottom 33 = SSOT 원좌표. 진입 시 refreshDaily·finalize.
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
      body: Stack(
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
          // 공통 헤더 (SSOT logo top 70 / coin top 72)
          const Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: FitzyHeader(),
          ),
          // 떠 있는 네비 (살짝 크게 + 더 아래로)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNav(currentIndex: _index, onTap: _select),
            ),
          ),
        ],
      ),
    );
  }
}

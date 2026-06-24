import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mood_fits.dart';
import '../providers/board_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Select(Pick Your Fit) — SSOT 자판기 번역.
/// 절대좌표는 SSOT(393×852, 상태바 54) 기준에서 (y-54)로 SafeArea에 매핑.
/// 슬롯 탭 = 뽑기(코인 소모→무드 확정→Board). 로직 불변.
class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key, required this.onDrawn});

  final VoidCallback onDrawn;

  static const List<String> _cols = ['A', 'B', 'C'];
  static const List<double> _slotLeft = [1, 90, 177];
  static const List<double> _slotTop = [10, 190, 372];

  Future<void> _draw(BuildContext context, String moodId) async {
    final coin = context.read<CoinProvider>();
    final board = context.read<BoardProvider>();
    if (!coin.canDraw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘은 이미 뽑았어요. 내일 다시!')),
      );
      return;
    }
    final now = DateTime.now();
    final ok = await coin.consumeForDraw();
    if (!ok) return;
    await board.createTodayRecord(moodId, now);
    onDrawn();
  }

  @override
  Widget build(BuildContext context) {
    final gender = context.watch<ProfileProvider>().profile?.gender ?? 'girl';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Pick Your Fit (top 154 - 54)
        const Positioned(
          left: 20,
          top: 100,
          child: Text('Pick Your Fit', style: AppTextStyles.eyebrow),
        ),
        // 자판기 (top 177 - 54)
        Positioned(
          left: 20,
          top: 123,
          child: _machine(context, gender),
        ),
        // 컨트롤 패널 (top 344 - 54)
        const Positioned(
          left: 300,
          top: 290,
          child: _ControlPanel(),
        ),
      ],
    );
  }

  Widget _machine(BuildContext context, String gender) {
    return SizedBox(
      width: 259,
      height: 560,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/vending/back.png', fit: BoxFit.fill),
          ),
          for (var i = 0; i < 9; i++) _slot(context, i, gender),
        ],
      ),
    );
  }

  Widget _slot(BuildContext context, int i, String gender) {
    final col = i % 3;
    final row = i ~/ 3;
    final mood = kMoodFits[i];
    final label = '${_cols[row]}${col + 1}';
    final modelW = col == 0 ? 116.0 : 118.0;
    final modelH = row == 2 ? 170.0 : 174.0;
    return Positioned(
      left: _slotLeft[col],
      top: _slotTop[row],
      width: 84,
      height: 173,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _draw(context, mood.id),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  mood.imageAssetFor(gender),
                  width: modelW,
                  height: modelH,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: -3,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/vending/pin.png',
                  width: 55,
                  height: 55,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 3,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 37,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(label, style: AppTextStyles.fitLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 우측 컨트롤 패널: INSERT COIN / RETURN / 키패드 (장식, SSOT 충실).
class _ControlPanel extends StatelessWidget {
  const _ControlPanel();

  static const List<String> _keys = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    '1', '2', '3', '4', '5', '6',
  ];

  static BoxDecoration get _cardDeco => BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 73,
      child: Column(
        children: [
          _insertCard(),
          const SizedBox(height: 6),
          _returnCard(),
          const SizedBox(height: 6),
          _keypadCard(),
        ],
      ),
    );
  }

  Widget _insertCard() {
    return Container(
      width: 73,
      height: 179,
      clipBehavior: Clip.antiAlias,
      decoration: _cardDeco,
      child: Stack(
        children: [
          const Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Text(
              'INSERT\nCOIN',
              textAlign: TextAlign.center,
              style: AppTextStyles.panelTitle,
            ),
          ),
          const Positioned(
            left: 30,
            top: 55,
            child: CustomPaint(size: Size(8, 6), painter: _DownTriangle()),
          ),
          Positioned(
            left: 26,
            top: 72,
            child: Container(
              width: 18,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 5,
                    top: 6,
                    child: Container(
                      width: 6,
                      height: 73,
                      decoration: BoxDecoration(
                        color: AppColors.labelPrimary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _returnCard() {
    return Container(
      width: 73,
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: _cardDeco,
      child: Stack(
        children: [
          const Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Text(
              'RETURN',
              textAlign: TextAlign.center,
              style: AppTextStyles.panelTitle,
            ),
          ),
          Positioned(
            left: 6,
            top: 34,
            child: Container(
              width: 59,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.coin,
                border: Border.all(color: AppColors.lineSoft),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 13,
                    top: 10,
                    child: Container(
                      width: 30,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _keypadCard() {
    return Container(
      width: 73,
      height: 137,
      clipBehavior: Clip.antiAlias,
      decoration: _cardDeco,
      child: Stack(
        children: [
          Positioned(
            left: 3,
            top: 4,
            child: SizedBox(
              width: 64,
              child: Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [for (final k in _keys) _key(k)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(String k) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.lineSoft, width: 0.5),
        shape: BoxShape.circle,
      ),
      child: Text(k, style: AppTextStyles.keyLabel),
    );
  }
}

/// 아래로 향하는 작은 삼각형 (INSERT COIN 화살표).
class _DownTriangle extends CustomPainter {
  const _DownTriangle();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.labelPrimary;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

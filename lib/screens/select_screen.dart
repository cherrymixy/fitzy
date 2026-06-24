import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mood_fits.dart';
import '../models/mood_fit.dart';
import '../providers/board_provider.dart';
import '../providers/coin_provider.dart';

/// Select(Pick Your Fit) — 3×3 무드 그리드 + INSERT COIN.
/// 코인 있으면 무드 픽 → 코인 소모 → 오늘 무드 확정 → Board 탭으로.
class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key, required this.onDrawn});

  /// 뽑기 성공(또는 보드 보기) 시 Board 탭으로 전환.
  final VoidCallback onDrawn;

  Future<void> _draw(BuildContext context, String moodId) async {
    final coin = context.read<CoinProvider>();
    final board = context.read<BoardProvider>();
    if (!coin.canDraw) return;
    final now = DateTime.now();
    final ok = await coin.consumeForDraw();
    if (!ok) return;
    await board.createTodayRecord(moodId, now);
    onDrawn();
  }

  @override
  Widget build(BuildContext context) {
    final canDraw = context.watch<CoinProvider>().canDraw;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                canDraw
                    ? 'INSERT COIN — 오늘의 추구미를 하나 뽑으세요'
                    : '오늘은 이미 뽑았어요. 내일 다시!',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (var i = 0; i < kMoodFits.length; i++)
                    _MoodCell(
                      index: i,
                      mood: kMoodFits[i],
                      enabled: canDraw,
                      onTap: () => _draw(context, kMoodFits[i].id),
                    ),
                ],
              ),
            ),
            if (!canDraw) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onDrawn,
                child: const Text('오늘 보드 보기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoodCell extends StatelessWidget {
  const _MoodCell({
    required this.index,
    required this.mood,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final MoodFit mood;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFEDEDED) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'J${index + 1}',
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const SizedBox(height: 4),
            Text(
              mood.nameKo,
              style: TextStyle(color: enabled ? Colors.black : Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}

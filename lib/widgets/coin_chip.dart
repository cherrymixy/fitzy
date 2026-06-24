import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/coin_provider.dart';

/// 상단 코인 칩(회색박스): 오늘 보유 코인 수.
class CoinChip extends StatelessWidget {
  const CoinChip({super.key});

  @override
  Widget build(BuildContext context) {
    final coin = context.watch<CoinProvider>().coin;
    final count = coin.hasCoinToday ? 1 : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_outlined, size: 16),
          const SizedBox(width: 4),
          Text('$count'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/coin_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 공통 상단: 좌측 FITZY 로고 + 우측 코인 칩 (SSOT shell).
class FitzyHeader extends StatelessWidget {
  const FitzyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final coin = context.watch<CoinProvider>().coin;
    final count = coin.hasCoinToday ? 1 : 0;
    return Row(
      children: [
        SvgPicture.asset('assets/images/logo.svg', width: 122),
        const Spacer(),
        _CoinPill(count: count),
      ],
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.only(left: 6, right: 9),
      decoration: BoxDecoration(
        color: AppColors.coin,
        borderRadius: BorderRadius.circular(56),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/icons/coin.svg', width: 24, height: 24),
          const SizedBox(width: 6),
          Text('$count', style: AppTextStyles.tab),
        ],
      ),
    );
  }
}

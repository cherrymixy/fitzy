import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 하단 떠 있는 반투명 알약 네비 (SSOT .nav).
/// 활성 항목은 어두운 알약 + 라벨, 비활성은 아이콘만.
class FloatingNav extends StatelessWidget {
  const FloatingNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<(String, String)> _items = [
    ('assets/images/icons/closet.svg', 'Select'),
    ('assets/images/icons/board.svg', 'Board'),
    ('assets/images/icons/calendar.svg', 'Calendar'),
    ('assets/images/icons/user.svg', 'My'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(56),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.5, sigmaY: 8.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(56),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 4, spreadRadius: 2),
              BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _items.length; i++) ...[
                if (i > 0) const SizedBox(width: 22),
                _NavItem(
                  icon: _items[i].$1,
                  label: _items[i].$2,
                  active: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      icon,
      width: 26,
      height: 26,
      colorFilter: ColorFilter.mode(
        active ? Colors.white : AppColors.muted,
        BlendMode.srcIn,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: active
          ? Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(56),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  svg,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.tab.copyWith(color: Colors.white),
                  ),
                ],
              ),
            )
          : SizedBox(height: 42, width: 26, child: Center(child: svg)),
    );
  }
}

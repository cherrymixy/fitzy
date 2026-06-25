import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 하단 떠 있는 반투명 알약 네비 (SSOT .nav).
/// 활성 항목은 어두운 알약 + 라벨, 비활성은 아이콘만.
/// 탭 이동 시 알약이 쫀득하게(오버슈트) 늘어나고, 누르면 살짝 눌린다.
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
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
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
                  reduceMotion: reduceMotion,
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

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.reduceMotion,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.reduceMotion) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final morph = widget.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 420);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: widget.active ? 1.0 : 0.0),
          duration: morph,
          curve: Curves.easeOutBack, // 오버슈트 = 쫀득
          builder: (context, t, _) {
            final tc = t.clamp(0.0, 1.0);
            return Container(
              height: 42,
              // 패딩은 raw t로 살짝 오버슈트(부푸는 느낌)
              padding: EdgeInsets.symmetric(horizontal: (8 + 8 * t).clamp(6.0, 20.0)),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: tc),
                borderRadius: BorderRadius.circular(56),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    width: 26,
                    height: 26,
                    colorFilter: ColorFilter.mode(
                      Color.lerp(AppColors.muted, Colors.white, tc)!,
                      BlendMode.srcIn,
                    ),
                  ),
                  // 라벨: 폭(widthFactor)으로 좌→우 펼쳐지며 페이드인
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: tc,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Opacity(
                          opacity: tc,
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            softWrap: false,
                            style: AppTextStyles.tab.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

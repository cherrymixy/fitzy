import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../services/image_store_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/local_image.dart';
import '../widgets/profile_edit_sheet.dart';

/// My — SSOT 번역. 프로필 원/편집 버튼/닉네임·메타/태그/구분선/메뉴 리스트.
/// 절대좌표는 SSOT(393×852, 풀프레임) 기준. 데이터는 ProfileProvider.
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  void _soon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — 준비 중')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    if (profile == null) {
      return const Center(child: Text('프로필 없음'));
    }
    final genderText = profile.genderPrivate ? '비공개' : profile.gender;

    return Stack(
      children: [
        // 프로필 원 (SSOT left 111, top 146, 171×171)
        Positioned(left: 111, top: 146, child: _circle(context, profile)),
        // 편집 버튼 (SSOT left 240, top 277, 40×40)
        Positioned(left: 240, top: 277, child: _editButton(context)),
        // 닉네임 + 메타 (SSOT left 20, top 342, width 353, 중앙)
        Positioned(
          left: 20,
          top: 342,
          width: 353,
          child: Column(
            children: [
              Text(profile.nickname, style: AppTextStyles.title),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('@${profile.userId}', style: AppTextStyles.caption),
                  const SizedBox(width: 8),
                  const Text('|', style: AppTextStyles.caption),
                  const SizedBox(width: 8),
                  Text(genderText, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
        // 태그 (SSOT 중앙, top 421)
        if (profile.tags.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            top: 421,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < profile.tags.length; i++) ...[
                    if (i > 0) const SizedBox(width: 7),
                    _tagChip(profile.tags[i]),
                  ],
                ],
              ),
            ),
          ),
        // 구분선 (SSOT left 0, top 496, 풀폭 5px)
        const Positioned(
          left: 0,
          right: 0,
          top: 496,
          child: SizedBox(
            height: 5,
            child: ColoredBox(color: AppColors.dividerSoft),
          ),
        ),
        // 메뉴 (SSOT left 20, top 526, width 353, gap 21)
        Positioned(
          left: 20,
          top: 526,
          width: 353,
          child: Column(
            children: [
              _menuRow(context, '설정'),
              const SizedBox(height: 21),
              _menuRow(context, '공지사항'),
              const SizedBox(height: 21),
              _menuRow(context, '고객센터'),
              const SizedBox(height: 21),
              _logoutRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circle(BuildContext context, UserProfile profile) {
    return Container(
      width: 171,
      height: 171,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
      ),
      child: profile.profileImagePath != null
          ? localImage(
              context.read<ImageStoreService>()
                  .resolve(profile.profileImagePath!),
              fit: BoxFit.cover,
              error: _avatarFallback(),
            )
          : _avatarFallback(),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: SvgPicture.asset(
        'assets/images/icons/user.svg',
        width: 64,
        height: 64,
        colorFilter: const ColorFilter.mode(
          AppColors.lineSoft,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _editButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showProfileEditSheet(context),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkButton,
        ),
        child: SvgPicture.asset(
          'assets/images/icons/pen.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.coin,
        borderRadius: BorderRadius.circular(56),
      ),
      child: Text('#$tag', style: AppTextStyles.tag),
    );
  }

  Widget _menuRow(BuildContext context, String label) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _soon(context, label),
      child: SizedBox(
        height: 27,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.menuRow),
            SvgPicture.asset(
              'assets/images/icons/arrow-right.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.muted,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutRow(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _confirmLogout(context),
      child: SizedBox(
        height: 27,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '로그아웃',
            style: AppTextStyles.menuRow.copyWith(color: AppColors.subText),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃할까요? 기록은 기기에 그대로 남아요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (ok == true) await provider.logout();
  }
}

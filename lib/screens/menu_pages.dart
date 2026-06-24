import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/legal_text.dart';
import '../data/notices.dart';
import '../data/support_faq.dart';
import '../providers/board_provider.dart';
import '../providers/coin_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/legal_sheet.dart';

/// My 메뉴(설정/공지/고객센터)에서 푸시되는 서브 페이지들.
/// 셸 위에 풀스크린으로 열리고 백 셰브론으로 돌아간다.

class _SubScaffold extends StatelessWidget {
  const _SubScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 20, color: Color(0xFF202020)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ---------- 설정 ----------

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScaffold(
      title: '설정',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _row('버전', value: '1.0.0'),
          _row('이용약관',
              onTap: () =>
                  showLegalSheet(context, '서비스 이용약관', kTermsOfService)),
          _row('개인정보 취급방침',
              onTap: () =>
                  showLegalSheet(context, '개인정보 취급방침', kPrivacyPolicy)),
          const Divider(color: AppColors.dividerSoft, height: 24),
          _row('데이터 초기화',
              danger: true, onTap: () => _confirmErase(context)),
        ],
      ),
    );
  }

  Widget _row(String label,
      {String? value, VoidCallback? onTap, bool danger = false}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: danger ? const Color(0xFFE05A5A) : AppColors.text,
              ),
            ),
            const Spacer(),
            if (value != null)
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.subText))
            else if (onTap != null && !danger)
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmErase(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 기록과 계정 정보가 삭제돼요. 되돌릴 수 없어요. 초기화할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<ProfileProvider>().eraseAllData();
    if (!context.mounted) return;
    await context.read<CoinProvider>().reset();
    if (!context.mounted) return;
    await context.read<BoardProvider>().reset();
    if (!context.mounted) return;
    Navigator.pop(context); // 설정 닫기 → RootGate가 인증 플로우로
  }
}

// ---------- 공지사항 ----------

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScaffold(
      title: '공지사항',
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kNotices.length,
        separatorBuilder: (_, _) =>
            const Divider(color: AppColors.dividerSoft, height: 1),
        itemBuilder: (_, i) {
          final n = kNotices[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.date,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subText)),
                const SizedBox(height: 6),
                Text(n.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
                const SizedBox(height: 8),
                Text(n.body,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.grayNormal)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------- 고객센터 ----------

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScaffold(
      title: '고객센터',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text('자주 묻는 질문',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grayNormal)),
          ),
          for (final f in kFaq)
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 14),
                title: Text('Q. ${f.q}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(f.a,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.grayNormal)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _email(context),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('문의하기',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(kSupportEmail,
                style: TextStyle(fontSize: 12, color: AppColors.subText)),
          ),
        ],
      ),
    );
  }

  Future<void> _email(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      query: 'subject=${Uri.encodeComponent('FITZY 문의')}',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없어요. $kSupportEmail 로 보내주세요.')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import 'auth_flow.dart';
import 'main_shell.dart';

/// 첫/재실행 분기.
/// - 최초 load 전: 빈 셸
/// - 프로필 있음: 메인
/// - 프로필 없음: 인증 플로우(start → 온보딩 → 회원가입 / 로그인)
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    if (!profile.loaded) {
      return const Scaffold(body: Center(child: Text('…')));
    }
    return profile.hasProfile ? const MainShell() : const AuthFlow();
  }
}

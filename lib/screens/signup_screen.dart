import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

/// 최소 회원가입(회색박스). 닉네임·아이디·성별 필수, 태그·이미지 선택.
/// 성공 시 프로필이 생기고 RootGate가 메인으로 자동 전환한다(별도 네비 불필요).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _userId = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  String? _gender; // 'girl' | 'boy' (필수)
  bool _genderPrivate = false;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _nickname.dispose();
    _userId.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final tags = _tags.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final error = await context.read<ProfileProvider>().createProfile(
          userId: _userId.text.trim(),
          nickname: _nickname.text,
          gender: _gender ?? '',
          genderPrivate: _genderPrivate,
          tags: tags,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _error = error;
        _submitting = false;
      });
    }
    // 성공 시: ProfileProvider notify → RootGate가 메인으로 전환.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입 (최소)')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('닉네임 *'),
            TextField(controller: _nickname),
            const SizedBox(height: 16),
            const Text('아이디 * (영소문자·숫자·_ 4~20)'),
            TextField(
              controller: _userId,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(hintText: 'fitzy_user'),
            ),
            const SizedBox(height: 16),
            const Text('성별 *'),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('girl'),
                  selected: _gender == 'girl',
                  onSelected: (_) => setState(() => _gender = 'girl'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('boy'),
                  selected: _gender == 'boy',
                  onSelected: (_) => setState(() => _gender = 'boy'),
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('성별 비공개'),
              value: _genderPrivate,
              onChanged: (v) => setState(() => _genderPrivate = v ?? false),
            ),
            const SizedBox(height: 8),
            const Text('태그 (선택, 쉼표 구분)'),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(hintText: '러블리, 미니멀'),
            ),
            const SizedBox(height: 16),
            // 프로필 이미지(선택): image_picker 연결은 후속 단계. 지금은 자리만.
            Container(
              height: 80,
              color: const Color(0xFFE0E0E0),
              alignment: Alignment.center,
              child: const Text('프로필 이미지 (선택) — 자리'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '저장 중…' : '완료'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

/// My — 프로필(이미지/닉네임/@아이디/성별/태그) + 설정·공지·고객센터 리스트.
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    if (profile == null) {
      return const Center(child: Text('프로필 없음'));
    }
    final genderText = profile.genderPrivate ? '비공개' : profile.gender;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 100),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: profile.profileImagePath != null
                    ? FileImage(File(profile.profileImagePath!))
                    : null,
                child: profile.profileImagePath == null
                    ? const Icon(Icons.person, size: 32, color: Colors.black45)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${profile.userId} · $genderText',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final t in profile.tags) Chip(label: Text('#$t')),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const _MyTile(icon: Icons.settings_outlined, label: '설정'),
          const _MyTile(icon: Icons.campaign_outlined, label: '공지사항'),
          const _MyTile(icon: Icons.headset_mic_outlined, label: '고객센터'),
        ],
      ),
    );
  }
}

class _MyTile extends StatelessWidget {
  const _MyTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label — 준비 중')),
      ),
    );
  }
}

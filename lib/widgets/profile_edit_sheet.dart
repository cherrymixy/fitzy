import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../services/image_store_service.dart';
import '../theme/app_colors.dart';
import 'local_image.dart';

/// 프로필 편집 바텀시트 — 닉네임·태그·프로필 이미지 변경.
/// My의 연필 버튼에서 호출. 저장은 ProfileProvider.updateProfile.
Future<void> showProfileEditSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ProfileEditSheet(),
  );
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet();

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _nick;
  late final TextEditingController _tags;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile;
    _nick = TextEditingController(text: p?.nickname ?? '');
    _tags = TextEditingController(text: (p?.tags ?? const <String>[]).join(', '));
    _imagePath = p?.profileImagePath;
  }

  @override
  void dispose() {
    _nick.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final store = context.read<ImageStoreService>();
    final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f == null) return;
    final saved =
        await store.save(f.path, dateKey: 'profile', categoryId: 'avatar');
    if (!mounted) return;
    setState(() => _imagePath = saved);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final tags = _tags.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final err = await context.read<ProfileProvider>().updateProfile(
          nickname: _nick.text,
          tags: tags,
          profileImagePath: _imagePath,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lineSoft,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '프로필 편집',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          Center(child: _avatar()),
          const SizedBox(height: 24),
          _label('닉네임'),
          _field(_nick, '닉네임', maxLen: 12),
          const SizedBox(height: 16),
          _label('태그'),
          _field(_tags, '쉼표로 구분 (러블리, 미니멀)'),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final store = context.read<ImageStoreService>();
    return GestureDetector(
      onTap: _pick,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
              ),
              child: _imagePath == null
                  ? _fallback()
                  : localImage(store.resolve(_imagePath!),
                      fit: BoxFit.cover, error: _fallback()),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkButton,
                ),
                child: SvgPicture.asset(
                  'assets/images/icons/pen.svg',
                  width: 16,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Center(
        child: SvgPicture.asset(
          'assets/images/icons/user.svg',
          width: 40,
          colorFilter:
              const ColorFilter.mode(AppColors.lineSoft, BlendMode.srcIn),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grayNormal,
          ),
        ),
      );

  Widget _field(TextEditingController c, String hint, {int? maxLen}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: c,
        maxLength: maxLen,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          counterText: '',
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.graySubtle,
          ),
        ),
      ),
    );
  }
}

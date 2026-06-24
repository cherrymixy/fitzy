import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/board_categories.dart';
import '../models/day_record.dart';
import '../providers/board_provider.dart';
import '../services/date_keys.dart';
import '../services/image_store_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/local_image.dart';

/// Board — SSOT 번역. 제목(편집)/날짜/N images/하트 + 3×3 셀 + 이미지 추가.
/// 절대좌표는 SSOT(393×852, 풀프레임) 기준. 셀/제목/하트 로직 불변.
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, this.dateKey});

  final String? dateKey;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String get _key => widget.dateKey ?? dateKeyOf(DateTime.now());

  Future<ImageSource?> _askSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickInto(String categoryId) async {
    final board = context.read<BoardProvider>();
    final source = await _askSource();
    if (source == null) return;
    try {
      final XFile? file = await ImagePicker().pickImage(source: source);
      if (file == null) return;
      await board.setCellImage(_key, categoryId, file.path);
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        await _showPermissionDialog(source);
      }
    }
  }

  /// 권한 거부 안내 + 설정 유도.
  Future<void> _showPermissionDialog(ImageSource source) async {
    final what = source == ImageSource.camera ? '카메라' : '사진';
    final open = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$what 접근 권한 필요'),
        content: Text('$what 접근이 거부되어 있어요.\n설정 > FITZY에서 권한을 허용해 주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
    if (open == true) {
      await launchUrl(Uri.parse('app-settings:'));
    }
  }

  Future<void> _editFilled(String categoryId) async {
    final board = context.read<BoardProvider>();
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('교체'),
              onTap: () => Navigator.pop(context, 'replace'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('삭제'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'replace') {
      if (!mounted) return;
      await _pickInto(categoryId);
    } else if (action == 'delete') {
      await board.clearCellImage(_key, categoryId);
    }
  }

  Future<void> _onCellTap(DayRecord record, String categoryId) async {
    if (record.finalized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마감된 보드는 이미지를 수정할 수 없어요.')),
      );
      return;
    }
    if (record.cells[categoryId] == null) {
      await _pickInto(categoryId);
    } else {
      await _editFilled(categoryId);
    }
  }

  Future<void> _addFirstEmpty(DayRecord record) async {
    if (record.finalized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마감된 보드는 이미지를 추가할 수 없어요.')),
      );
      return;
    }
    final empty = kBoardCategories
        .where((c) => record.cells[c.id] == null)
        .map((c) => c.id)
        .toList();
    if (empty.isEmpty) return;
    await _pickInto(empty.first);
  }

  Future<void> _editTitle(DayRecord record) async {
    final board = context.read<BoardProvider>();
    final controller = TextEditingController(text: record.moodTitle);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('제목 편집'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await board.editTitle(record.dateKey, result.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = context.watch<BoardProvider>().recordOn(_key);
    if (record == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            '아직 오늘 무드를 안 뽑았어요.\nSelect 탭에서 무드를 뽑아 보드를 시작하세요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    // 기기 폭에 맞춰 셀 크기 산출(좌우 20 패딩, 가로 간격 10×2).
    final contentW = MediaQuery.of(context).size.width - 40;
    final cell = (contentW - 20) / 3;
    return Stack(
      children: [
        // 제목 블록 (SSOT top 146)
        Positioned(left: 20, right: 20, top: 146, child: _title(record)),
        // 3×3 그리드 (SSOT top 231)
        Positioned(left: 20, top: 231, child: _grid(record, contentW, cell)),
        // 이미지 추가 (SSOT top 623)
        Positioned(left: 20, right: 20, top: 623, child: _addButton(record)),
      ],
    );
  }

  Widget _title(DayRecord record) {
    final date = record.dateKey.replaceAll('-', '.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _editTitle(record),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        record.moodTitle,
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Opacity(
                        opacity: 0.7,
                        child: SvgPicture.asset(
                          'assets/images/icons/pen.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  context.read<BoardProvider>().toggleFavorite(record.dateKey),
              child: SvgPicture.asset(
                'assets/images/icons/heart.svg',
                width: 24,
                height: 24,
                colorFilter: record.isFavorite
                    ? null // 자연색 #1C274C (즐겨찾기)
                    : const ColorFilter.mode(AppColors.subText, BlendMode.srcIn),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(date, style: AppTextStyles.caption),
            const SizedBox(width: 8),
            const Text('|', style: AppTextStyles.caption),
            const SizedBox(width: 8),
            Text('${record.filledCount} images', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _grid(DayRecord record, double width, double cell) {
    return SizedBox(
      width: width,
      child: Wrap(
        spacing: 10,
        runSpacing: 13,
        children: [
          for (final category in kBoardCategories)
            _cell(record, category.id, category.labelEn, cell),
        ],
      ),
    );
  }

  Widget _cell(DayRecord record, String categoryId, String label, double size) {
    final path = record.cells[categoryId];
    return GestureDetector(
      onTap: () => _onCellTap(record, categoryId),
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        child: path != null
            ? _PopIn(
                animate:
                    !(MediaQuery.maybeOf(context)?.disableAnimations ?? false),
                child: localImage(
                  context.read<ImageStoreService>().resolve(path),
                  width: size,
                  height: size,
                  error: Center(
                    child: Text(label, style: AppTextStyles.category),
                  ),
                ),
              )
            : Center(child: Text(label, style: AppTextStyles.category)),
      ),
    );
  }

  // (연출은 파일 하단 _PopIn 위젯 참고)

  Widget _addButton(DayRecord record) {
    return GestureDetector(
      onTap: () => _addFirstEmpty(record),
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('이미지 추가', style: AppTextStyles.tab),
      ),
    );
  }
}

/// 셀 이미지 등장 연출: 0.85→1.0 스케일 팝 (250ms, Curves.easeOutBack).
/// 모션 줄이기(disableAnimations)면 애니메이션 없이 즉시 표시.
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child, required this.animate});

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: child,
      builder: (_, value, c) => Transform.scale(scale: value, child: c),
    );
  }
}


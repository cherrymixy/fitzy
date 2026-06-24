import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/board_categories.dart';
import '../models/day_record.dart';
import '../providers/board_provider.dart';
import '../services/date_keys.dart';
import '../services/image_store_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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
    final XFile? file = await ImagePicker().pickImage(source: source);
    if (file == null) return;
    await board.setCellImage(_key, categoryId, file.path);
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
    return Stack(
      children: [
        // 제목 블록 (SSOT top 146)
        Positioned(left: 20, top: 146, width: 353, child: _title(record)),
        // 3×3 그리드 (SSOT top 231)
        Positioned(left: 20, top: 231, child: _grid(record)),
        // 이미지 추가 (SSOT top 623)
        Positioned(left: 20, top: 623, child: _addButton(record)),
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

  Widget _grid(DayRecord record) {
    return SizedBox(
      width: 353,
      child: Wrap(
        spacing: 10,
        runSpacing: 13,
        children: [
          for (final category in kBoardCategories)
            _cell(record, category.id, category.labelEn),
        ],
      ),
    );
  }

  Widget _cell(DayRecord record, String categoryId, String label) {
    final path = record.cells[categoryId];
    return GestureDetector(
      onTap: () => _onCellTap(record, categoryId),
      child: Container(
        width: 111,
        height: 111,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        child: path != null
            ? Image.file(
                File(context.read<ImageStoreService>().resolve(path)),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Center(child: Text(label, style: AppTextStyles.category)),
              )
            : Center(child: Text(label, style: AppTextStyles.category)),
      ),
    );
  }

  Widget _addButton(DayRecord record) {
    return GestureDetector(
      onTap: () => _addFirstEmpty(record),
      child: Container(
        width: 353,
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

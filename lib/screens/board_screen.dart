import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/board_categories.dart';
import '../models/day_record.dart';
import '../providers/board_provider.dart';
import '../services/date_keys.dart';

/// Board — 오늘(또는 지정 날짜) 무드 보드. 9칸을 카메라/갤러리 이미지로 채운다.
/// 빈 칸 탭→추가, 채운 칸 탭→교체/삭제. 마감되면 이미지만 잠금(제목·하트는 허용).
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
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '아직 오늘 무드를 안 뽑았어요.\nSelect 탭에서 무드를 뽑아 보드를 시작하세요.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              record.moodTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _editTitle(record),
                          ),
                        ],
                      ),
                      Text(
                        '${record.dateKey}${record.finalized ? ' · 마감됨' : ''}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text('${record.filledCount}/${DayRecord.cellCount} images'),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    record.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: record.isFavorite ? Colors.red : null,
                  onPressed: () =>
                      context.read<BoardProvider>().toggleFavorite(record.dateKey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final category in kBoardCategories)
                    _Cell(
                      label: category.labelEn,
                      path: record.cells[category.id],
                      onTap: () => _onCellTap(record, category.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              record.finalized ? '마감된 보드' : '빈 칸을 탭해 이미지를 추가하세요',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.path, required this.onTap});

  final String label;
  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: const Color(0xFFEDEDED),
          child: path != null
              ? Image.file(File(path!), fit: BoxFit.cover)
              : Center(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mood_fits.dart';
import '../models/day_record.dart';
import '../providers/board_provider.dart';
import '../services/date_keys.dart';
import 'board_screen.dart';

/// Calendar — 월 그리드. 완성 보드만 날짜에 썸네일, 하단 월 통계.
/// 날짜 탭 → 그날 보드(읽기 전용 가능).
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  String? _thumb(DayRecord r) {
    for (final p in r.cells.values) {
      if (p != null) return p;
    }
    return null;
  }

  void _openDay(String dateKey) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(dateKey)),
          body: BoardScreen(dateKey: dateKey),
        ),
      ),
    );
  }

  String _topMoodKo(List<DayRecord> records) {
    if (records.isEmpty) return '-';
    final counts = <String, int>{};
    for (final r in records) {
      counts[r.moodFitId] = (counts[r.moodFitId] ?? 0) + 1;
    }
    final topId =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return kMoodFits.firstWhere((m) => m.id == topId).nameKo;
  }

  @override
  Widget build(BuildContext context) {
    final board = context.watch<BoardProvider>();
    final completed = <String, DayRecord>{
      for (final r in board.completedRecords) r.dateKey: r,
    };

    final monthPrefix =
        '${_month.year.toString().padLeft(4, '0')}-${_month.month.toString().padLeft(2, '0')}';
    final monthCompleted = completed.values
        .where((r) => r.dateKey.startsWith(monthPrefix))
        .toList();

    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7; // 일=0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final dateKey = dateKeyOf(DateTime(_month.year, _month.month, day));
      final record = completed[dateKey];
      cells.add(_DayCell(
        day: day,
        thumbPath: record == null ? null : _thumb(record),
        onTap: () => _openDay(dateKey),
      ));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftMonth(-1),
                ),
                Text(
                  monthPrefix,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftMonth(1),
                ),
              ],
            ),
            const Row(
              children: [
                _Wd('일'), _Wd('월'), _Wd('화'), _Wd('수'), _Wd('목'), _Wd('금'), _Wd('토'),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: cells,
              ),
            ),
            const Divider(),
            _Stats(
              days: monthCompleted.length,
              topMoodKo: _topMoodKo(monthCompleted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wd extends StatelessWidget {
  const _Wd(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.thumbPath,
    required this.onTap,
  });

  final int day;
  final String? thumbPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: thumbPath != null
                ? Image.file(File(thumbPath!), fit: BoxFit.cover)
                : const ColoredBox(color: Color(0xFFF2F2F2)),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 11,
                  color: thumbPath != null ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.days, required this.topMoodKo});

  final int days;
  final String topMoodKo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('이번 달 기록'),
              Text('$days일',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              const Text('가장 많이 기록한 무드'),
              Text(topMoodKo,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

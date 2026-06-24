import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../data/mood_fits.dart';
import '../models/day_record.dart';
import '../providers/board_provider.dart';
import '../services/date_keys.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'board_screen.dart';

/// Calendar — SSOT 번역. 월 헤더 + 요일 + 날짜 그리드(기록일=썸네일) + 월 통계.
/// 절대좌표는 SSOT(393×852, 풀프레임) 기준. 데이터는 BoardProvider.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;

  static const List<String> _weekdays = [
    'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT',
  ];

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
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned.fill(child: BoardScreen(dateKey: dateKey)),
              const Positioned(top: 50, left: 4, child: BackButton()),
            ],
          ),
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
        '${_month.year.toString().padLeft(4, '0')}.${_month.month.toString().padLeft(2, '0')}';
    final monthCompleted = completed.values
        .where((r) => r.dateKey.startsWith(monthPrefix.replaceAll('.', '-')))
        .toList();

    return Stack(
      children: [
        // 월 헤더 (SSOT left 118, top 146)
        Positioned(
          left: 118,
          top: 146,
          child: Row(
            children: [
              Text(monthPrefix, style: AppTextStyles.calendarMonth),
              const SizedBox(width: 23),
              GestureDetector(
                onTap: () => _shiftMonth(1),
                child: SvgPicture.asset(
                  'assets/images/icons/arrow-right.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        // 요일 (SSOT left 28, top 187, width 337)
        Positioned(
          left: 28,
          top: 187,
          width: 337,
          child: Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(child: Text(w, style: AppTextStyles.weekday)),
                ),
            ],
          ),
        ),
        // 날짜 그리드 (SSOT left 20, top 209) — 좌우 스와이프로 월 이동
        Positioned(
          left: 20,
          top: 209,
          child: GestureDetector(
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v > 0) {
                _shiftMonth(-1);
              } else if (v < 0) {
                _shiftMonth(1);
              }
            },
            child: _grid(completed),
          ),
        ),
        // 월 통계 (SSOT left 20, top 663)
        Positioned(
          left: 20,
          top: 663,
          child: _summary(monthCompleted.length, _topMoodKo(monthCompleted)),
        ),
      ],
    );
  }

  Widget _grid(Map<String, DayRecord> completed) {
    final first = DateTime(_month.year, _month.month, 1);
    final firstWeekday = first.weekday % 7; // 일=0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final start = first.subtract(Duration(days: firstWeekday));
    final rows = ((firstWeekday + daysInMonth + 6) ~/ 7);

    return SizedBox(
      width: 353,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            for (var r = 0; r < rows; r++)
              Container(
                height: 84,
                decoration: BoxDecoration(
                  border: r == rows - 1
                      ? null
                      : const Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    for (var c = 0; c < 7; c++)
                      _dateCell(start.add(Duration(days: r * 7 + c)), completed),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateCell(DateTime date, Map<String, DayRecord> completed) {
    final inMonth = date.month == _month.month;
    final key = dateKeyOf(date);
    final record = completed[key];
    final thumb = record == null ? null : _thumb(record);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openDay(key),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Text(
                '${date.day}',
                textAlign: TextAlign.center,
                style: AppTextStyles.weekday.copyWith(
                  color: inMonth
                      ? AppColors.text
                      : AppColors.text.withValues(alpha: 0.3),
                ),
              ),
            ),
            if (record != null)
              Positioned(
                top: 39,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: thumb != null
                        ? Image.file(
                            File(thumb),
                            width: 37,
                            height: 37,
                            fit: BoxFit.cover,
                          )
                        : const ColoredBox(
                            color: AppColors.thumbPlaceholder,
                            child: SizedBox(width: 37, height: 37),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summary(int days, String topMoodKo) {
    return Container(
      width: 353,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _summaryBlock(
              '이번 달 기록',
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$days', style: AppTextStyles.summaryValue),
                  const SizedBox(width: 4),
                  const Text('일', style: AppTextStyles.summaryUnit),
                ],
              ),
            ),
          ),
          const ColoredBox(
            color: AppColors.border,
            child: SizedBox(width: 1),
          ),
          Expanded(
            child: _summaryBlock(
              '가장 많이 기록한 무드',
              Text(topMoodKo, style: AppTextStyles.summaryValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBlock(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: Center(
        child: SizedBox(
          height: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.summaryLabel),
              value,
            ],
          ),
        ),
      ),
    );
  }
}

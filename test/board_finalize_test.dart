// 자정 마감(finalize) 경계 테스트(PRD §7-4,5). now 주입.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/models/day_record.dart';
import 'package:fitzy/providers/board_provider.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final yesterday = DateTime(2026, 6, 23, 10);
  final today = DateTime(2026, 6, 24, 10);

  Future<BoardProvider> board() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final provider = BoardProvider(StorageService(prefs), ImageStoreService());
    await provider.load();
    return provider;
  }

  test('어제 보드는 오늘 진입 시 마감, 오늘 보드는 그대로', () async {
    final b = await board();
    await b.createTodayRecord('lovely', yesterday); // 2026-06-23
    await b.createTodayRecord('chic', today); // 2026-06-24

    await b.finalizePastRecords(today);

    expect(b.recordOn('2026-06-23')!.finalized, isTrue);
    expect(b.recordOn('2026-06-24')!.finalized, isFalse);
  });

  test('마감 후 이미지 추가/수정 차단', () async {
    final b = await board();
    await b.createTodayRecord('lovely', yesterday);
    await b.finalizePastRecords(today);

    // 마감된 보드에 칸 채우기/비우기 시도 → 변화 없음
    await b.setCellImage('2026-06-23', 'food', '/tmp/picked.jpg');
    await b.clearCellImage('2026-06-23', 'food');
    expect(b.recordOn('2026-06-23')!.cells['food'], isNull);
    expect(b.recordOn('2026-06-23')!.filledCount, 0);
  });

  test('마감 후 제목·즐겨찾기는 허용', () async {
    final b = await board();
    await b.createTodayRecord('lovely', yesterday);
    await b.finalizePastRecords(today);

    await b.editTitle('2026-06-23', '어제의 러블리');
    await b.toggleFavorite('2026-06-23');

    final r = b.recordOn('2026-06-23')!;
    expect(r.finalized, isTrue);
    expect(r.moodTitle, '어제의 러블리');
    expect(r.isFavorite, isTrue);
  });

  test('마감은 영속화된다', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StorageService(prefs);
    final b = BoardProvider(repo, ImageStoreService());
    await b.load();
    await b.createTodayRecord('lovely', yesterday);
    await b.finalizePastRecords(today);

    final persisted = await repo.loadDayRecord('2026-06-23');
    expect(persisted!.finalized, isTrue);
  });

  test('완성 보드만 completedRecords에 노출', () async {
    final b = await board();
    // 부분(빈) 보드
    await b.createTodayRecord('lovely', today);
    expect(b.completedRecords, isEmpty);

    // 9칸 모두 채운 완성 보드를 직접 주입
    final full = DayRecord(
      dateKey: '2026-06-20',
      moodFitId: 'chic',
      moodTitle: '시크',
      cells: <String, String?>{
        for (final id in const [
          'food', 'outfit', 'color', 'hobby', 'place',
          'activity', 'music', 'work', 'drink',
        ])
          id: '/img/$id.jpg',
      },
      createdAt: today,
      updatedAt: today,
    );
    await b.upsert(full);

    expect(full.isComplete, isTrue);
    expect(b.completedRecords.map((r) => r.dateKey), contains('2026-06-20'));
    expect(b.completedRecords.length, 1);
  });
}

// 저장→로드 왕복: StorageService(경로 A)가 JSON 문자열로 영속화한 뒤
// 새 인스턴스에서 동일하게 복원하는지 검증(직렬화 계약).
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/models/day_record.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DayRecord 저장→로드 왕복', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.parse('2026-06-24T10:00:00');
    final record = DayRecord(
      dateKey: '2026-06-24',
      moodFitId: 'lovely',
      moodTitle: '러블리',
      cells: <String, String?>{
        'food': '/docs/board_images/2026-06-24_food_1.jpg',
        'outfit': null,
        'color': null,
        'hobby': null,
        'place': null,
        'activity': null,
        'music': null,
        'work': null,
        'drink': null,
      },
      isFavorite: true,
      finalized: false,
      createdAt: now,
      updatedAt: now,
    );

    // 저장
    await StorageService(prefs).saveDayRecord(record);

    // 새 인스턴스로 로드(같은 prefs 문자열에서 재파싱)
    final loaded = await StorageService(prefs).loadDayRecord('2026-06-24');

    expect(loaded, isNotNull);
    expect(loaded!.moodFitId, 'lovely');
    expect(loaded.moodTitle, '러블리');
    expect(loaded.cells['food'], '/docs/board_images/2026-06-24_food_1.jpg');
    expect(loaded.cells['outfit'], isNull);
    expect(loaded.isFavorite, isTrue);
    expect(loaded.finalized, isFalse);
    expect(loaded.filledCount, 1);
    expect(loaded.isComplete, isFalse);
    expect(loaded.createdAt, now);
    expect(loaded.updatedAt, now);
  });
}

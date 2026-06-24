// 코인 지급/뽑기 경계 테스트(PRD §7). now 주입으로 자정 경계 검증.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/models/coin_state.dart';
import 'package:fitzy/providers/board_provider.dart';
import 'package:fitzy/providers/coin_provider.dart';
import 'package:fitzy/services/date_keys.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 6, 24, 10);

  Future<(CoinProvider, BoardProvider, StorageService)> setup({
    CoinState? seedCoin,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StorageService(prefs);
    if (seedCoin != null) await repo.saveCoinState(seedCoin);
    final coin = CoinProvider(repo);
    final board = BoardProvider(repo, ImageStoreService());
    await coin.load();
    await board.load();
    return (coin, board, repo);
  }

  test('dateKeyOf: zero-pad', () {
    expect(dateKeyOf(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dateKeyOf(DateTime(2026, 6, 24, 23, 59)), '2026-06-24');
  });

  test('어제→오늘 리셋: 새 코인 지급 + drawnToday 리셋', () async {
    final (coin, _, _) = await setup(
      seedCoin: const CoinState(
        lastGrantedDateKey: '2026-06-23',
        hasCoinToday: false,
        drawnToday: true,
      ),
    );
    await coin.refreshDaily(today);
    expect(coin.coin.lastGrantedDateKey, '2026-06-24');
    expect(coin.coin.hasCoinToday, isTrue);
    expect(coin.coin.drawnToday, isFalse);
    expect(coin.canDraw, isTrue);
  });

  test('같은날 재지급 차단: 두 번째 refreshDaily는 변화 없음', () async {
    final (coin, _, _) = await setup();
    await coin.refreshDaily(today);
    await coin.consumeForDraw(); // 소모
    expect(coin.coin.drawnToday, isTrue);
    expect(coin.coin.hasCoinToday, isFalse);

    await coin.refreshDaily(today); // 같은 날 재진입
    expect(coin.coin.drawnToday, isTrue); // 여전히 뽑은 상태
    expect(coin.coin.hasCoinToday, isFalse); // 코인 안 늘어남
    expect(coin.canDraw, isFalse);
  });

  test('같은날 재뽑기 차단', () async {
    final (coin, _, _) = await setup();
    await coin.refreshDaily(today);
    expect(await coin.consumeForDraw(), isTrue); // 1회 성공
    expect(coin.canDraw, isFalse);
    expect(await coin.consumeForDraw(), isFalse); // 재뽑기 no-op
  });

  test('뽑은 뒤 무드 확정: DayRecord 생성·저장', () async {
    final (coin, board, repo) = await setup();
    await coin.refreshDaily(today);
    expect(await coin.consumeForDraw(), isTrue);
    await board.createTodayRecord('lovely', today);

    final record = board.recordOn('2026-06-24');
    expect(record, isNotNull);
    expect(record!.moodFitId, 'lovely');
    expect(record.moodTitle, '러블리'); // 기본 제목 = 무드명
    expect(record.cells.length, 9);
    expect(record.filledCount, 0);
    expect(record.isComplete, isFalse);
    expect(record.finalized, isFalse);

    final persisted = await repo.loadDayRecord('2026-06-24');
    expect(persisted, isNotNull);
    expect(persisted!.moodFitId, 'lovely');
  });

  test('오늘 보드 중복 생성 차단', () async {
    final (coin, board, _) = await setup();
    await coin.refreshDaily(today);
    await coin.consumeForDraw();
    await board.createTodayRecord('lovely', today);
    await board.createTodayRecord('chic', today); // 무시되어야 함
    expect(board.recordOn('2026-06-24')!.moodFitId, 'lovely');
  });

  test('이월 없음: 어제 미사용 코인도 오늘은 여전히 1', () async {
    final (coin, _, _) = await setup(
      seedCoin: const CoinState(
        lastGrantedDateKey: '2026-06-23',
        hasCoinToday: true,
        drawnToday: false,
      ),
    );
    await coin.refreshDaily(today);
    expect(coin.coin.hasCoinToday, isTrue); // 2가 아니라 1(boolean)
    expect(coin.coin.drawnToday, isFalse);
    expect(await coin.consumeForDraw(), isTrue);
    expect(await coin.consumeForDraw(), isFalse); // 하루 1회뿐
  });
}

// 전체 루프 통합 테스트(provider 계층, now 주입).
// 신규→가입→코인→픽→9칸→완성→캘린더, 같은날 재진입, 미완성 비노출, 다음날 마감.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitzy/data/board_categories.dart';
import 'package:fitzy/providers/board_provider.dart';
import 'package:fitzy/providers/coin_provider.dart';
import 'package:fitzy/providers/profile_provider.dart';
import 'package:fitzy/services/date_keys.dart';
import 'package:fitzy/services/image_store_service.dart';
import 'package:fitzy/services/storage_service.dart';

/// 파일시스템을 타지 않는 이미지 스토어(임시경로를 그대로 반환).
class _FakeImageStore extends ImageStoreService {
  @override
  Future<String> save(
    String pickedPath, {
    required String dateKey,
    required String categoryId,
  }) async =>
      pickedPath;

  @override
  Future<void> delete(String storedPath) async {}

  @override
  Future<String> replace({
    String? oldStoredPath,
    required String newPickedPath,
    required String dateKey,
    required String categoryId,
  }) async =>
      newPickedPath;
}

class _World {
  _World(this.repo, this.profile, this.coin, this.board);
  final StorageService repo;
  final ProfileProvider profile;
  final CoinProvider coin;
  final BoardProvider board;
}

Future<_World> _world() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final repo = StorageService(prefs);
  final w = _World(
    repo,
    ProfileProvider(repo),
    CoinProvider(repo),
    BoardProvider(repo, _FakeImageStore()),
  );
  await w.profile.load();
  await w.coin.load();
  await w.board.load();
  return w;
}

Future<void> _fill(BoardProvider board, String dateKey, int count) async {
  for (var i = 0; i < count; i++) {
    await board.setCellImage(dateKey, kBoardCategories[i].id, '/tmp/$i.jpg');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final day1 = DateTime(2026, 6, 24, 9);
  final day2 = DateTime(2026, 6, 25, 9);

  test('전체 루프: 신규→가입→픽(캐주얼)→9칸 완성→캘린더→재진입→다음날', () async {
    final w = await _world();
    final key1 = dateKeyOf(day1);
    final key2 = dateKeyOf(day2);

    // 신규
    expect(w.profile.hasProfile, isFalse);

    // 온보딩→프로필 저장
    final err = await w.profile.createProfile(
      userId: 'cherry',
      nickname: '체리',
      gender: 'girl',
      tags: const ['러블리'],
    );
    expect(err, isNull);
    expect(w.profile.hasProfile, isTrue);

    // 코인 1 지급
    await w.coin.refreshDaily(day1);
    expect(w.coin.coin.hasCoinToday, isTrue);
    expect(w.coin.canDraw, isTrue);

    // Select 픽(캐주얼) → 코인 소모 → 무드 확정
    expect(await w.coin.consumeForDraw(), isTrue);
    await w.board.createTodayRecord('casual', day1);
    expect(w.board.recordOn(key1)!.moodFitId, 'casual');
    expect(w.board.recordOn(key1)!.moodTitle, '캐주얼');

    // Board 9칸 채움(임시경로) → 완성
    await _fill(w.board, key1, 9);
    expect(w.board.recordOn(key1)!.filledCount, 9);
    expect(w.board.recordOn(key1)!.isComplete, isTrue);

    // Calendar 노출(완성 보드)
    expect(w.board.completedRecords.map((r) => r.dateKey), contains(key1));

    // 같은 날 재진입: 코인 0, 재뽑기 차단, Board 이어서
    await w.coin.refreshDaily(day1);
    expect(w.coin.coin.hasCoinToday, isFalse);
    expect(w.coin.canDraw, isFalse);
    expect(await w.coin.consumeForDraw(), isFalse);
    expect(w.board.recordOn(key1), isNotNull);

    // 다음날: 새 코인, 새 뽑기 가능, 어제 보드 finalized 유지
    await w.coin.refreshDaily(day2);
    expect(w.coin.canDraw, isTrue);
    await w.board.finalizePastRecords(day2);
    expect(w.board.recordOn(key1)!.finalized, isTrue);
    expect(await w.coin.consumeForDraw(), isTrue);
    await w.board.createTodayRecord('minimal', day2);
    expect(w.board.recordOn(key2)!.finalized, isFalse);
    expect(w.board.recordOn(key2)!.moodFitId, 'minimal');

    // 어제 보드는 마감됐어도 완성·노출 유지
    expect(w.board.completedRecords.map((r) => r.dateKey), contains(key1));

    // 영속화: 새 인스턴스로 로드해도 동일
    final reloaded = BoardProvider(w.repo, _FakeImageStore());
    await reloaded.load();
    expect(reloaded.recordOn(key1)!.finalized, isTrue);
    expect(reloaded.recordOn(key1)!.isComplete, isTrue);
  });

  test('미완성(8/9) 보드는 캘린더 비노출', () async {
    final w = await _world();
    final key = dateKeyOf(day1);

    await w.coin.refreshDaily(day1);
    await w.coin.consumeForDraw();
    await w.board.createTodayRecord('casual', day1);
    await _fill(w.board, key, 8);

    expect(w.board.recordOn(key)!.filledCount, 8);
    expect(w.board.recordOn(key)!.isComplete, isFalse);
    expect(w.board.completedRecords, isEmpty);
  });
}

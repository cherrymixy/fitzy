import 'package:flutter/foundation.dart';

import '../models/coin_state.dart';
import '../repositories/data_repository.dart';
import '../services/date_keys.dart';

/// 코인 상태 + 일일 지급/뽑기 규칙(PRD §7).
///
/// 호출 계약: 진입 시 [refreshDaily]를 먼저 부른 뒤 [canDraw]/[consumeForDraw]를
/// 쓴다. [now]는 주입(앱에선 DateTime.now()).
class CoinProvider extends ChangeNotifier {
  CoinProvider(this._repo);

  final DataRepository _repo;

  CoinState _coin = const CoinState();
  CoinState get coin => _coin;

  Future<void>? _loading;

  /// 멱등 로드: 여러 번 불러도 최초 1회만 실행.
  /// 진입 시 refreshDaily가 load 완료를 await하게 해 stale 덮어쓰기(경쟁)를 막는다.
  Future<void> load() => _loading ??= _load();

  /// 데이터 초기화용 — 멱등 가드를 풀고 저장소에서 다시 읽는다.
  Future<void> reset() {
    _loading = null;
    return load();
  }

  Future<void> _load() async {
    _coin = await _repo.loadCoinState();
    notifyListeners();
  }

  /// 코인 상태 갱신 후 즉시 저장.
  Future<void> setCoinState(CoinState state) async {
    _coin = state;
    await _repo.saveCoinState(state);
    notifyListeners();
  }

  /// 진입 시 일일 지급. 오늘 dateKey가 마지막 지급일과 다르면 코인 1 지급하고
  /// drawnToday 리셋. 같은 날이면 변화 없음(추가 지급 X, 이월 X).
  Future<void> refreshDaily(DateTime now) async {
    await load(); // 로드 완료 보장(경쟁 시 stale 덮어쓰기 방지)
    final today = dateKeyOf(now);
    if (_coin.lastGrantedDateKey == today) return; // 같은 날 → 변화 없음
    await setCoinState(CoinState(
      lastGrantedDateKey: today,
      hasCoinToday: true,
      drawnToday: false,
    ));
  }

  /// 오늘 뽑을 수 있는지(코인 있고 아직 안 뽑음). 진입 시 refreshDaily 선행 가정.
  bool get canDraw => _coin.hasCoinToday && !_coin.drawnToday;

  /// 뽑기 코인 소모. 가능하면 소모하고 true, 불가하면 변화 없이 false.
  Future<bool> consumeForDraw() async {
    if (!canDraw) return false;
    await setCoinState(CoinState(
      lastGrantedDateKey: _coin.lastGrantedDateKey,
      hasCoinToday: false,
      drawnToday: true,
    ));
    return true;
  }
}

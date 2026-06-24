import 'package:flutter/foundation.dart';

import '../models/coin_state.dart';
import '../repositories/data_repository.dart';

/// 코인 상태. DataRepository에만 의존, 변경 시 즉시 저장.
///
/// 지급/소모(뽑기) 규칙은 STEP 5에서 이 위에 얹는다. 여기서는 상태 보유와
/// 영속화 배선만.
class CoinProvider extends ChangeNotifier {
  CoinProvider(this._repo);

  final DataRepository _repo;

  CoinState _coin = const CoinState();
  CoinState get coin => _coin;

  Future<void> load() async {
    _coin = await _repo.loadCoinState();
    notifyListeners();
  }

  /// 코인 상태 갱신 후 즉시 저장.
  Future<void> setCoinState(CoinState state) async {
    _coin = state;
    await _repo.saveCoinState(state);
    notifyListeners();
  }
}

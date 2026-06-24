/// 코인 상태 (불변).
///
/// 규칙: 앱 진입 시 오늘 dateKey != lastGrantedDateKey면 1개 지급하고
/// drawnToday=false. 같은 날 추가 지급 없음, 이월 없음.
class CoinState {
  /// 마지막으로 코인을 지급한 날짜 키(yyyy-MM-dd). 미지급이면 null.
  final String? lastGrantedDateKey;

  /// 오늘 사용할 코인이 있는지(지급됐고 아직 안 뽑음).
  final bool hasCoinToday;

  /// 오늘 Select에서 이미 뽑았는지.
  final bool drawnToday;

  const CoinState({
    this.lastGrantedDateKey,
    this.hasCoinToday = false,
    this.drawnToday = false,
  });
}

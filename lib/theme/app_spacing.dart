/// 간격·라운드 토큰 — Figma 추출.
class AppSpacing {
  const AppSpacing._();

  // --- 여백 ---
  /// 화면 좌우 패딩 (left-[20px]).
  static const double screenPadding = 20;

  /// 섹션/요소 기본 간격 (Figma 변수 "8").
  static const double sectionGap = 8;

  // --- Board 3×3 그리드 간격 ---
  /// 가로 간격 — GridView crossAxisSpacing (gap-x-[10px]).
  static const double gridGapX = 10;

  /// 세로 간격 — GridView mainAxisSpacing (gap-y-[13px]).
  static const double gridGapY = 13;

  // --- 라운드 ---
  /// 작은 카드 (자판기 카드 rounded-[4px]).
  static const double radiusSmall = 4;

  /// 카드/버튼 (이미지 추가 rounded-[8px]).
  static const double radiusCard = 8;

  /// 알약형 — 하단 탭/코인 칩 (rounded-[56px]).
  static const double radiusPill = 56;
}

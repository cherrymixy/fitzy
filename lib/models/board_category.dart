/// 보드 9칸 카테고리 정의 — 3×3 그리드의 한 칸. 불변.
///
/// 그리드 순서:
///   (0,0) Food   (0,1) Outfit  (0,2) Color
///   (1,0) Hobby  (1,1) Place   (1,2) Activity
///   (2,0) Music  (2,1) Work    (2,2) Drink
class BoardCategory {
  /// 카테고리 id(= DayRecord.cells의 키). 예: 'food'.
  final String id;

  /// 영문 라벨. 예: 'Food'.
  final String labelEn;

  /// 그리드 행(0~2).
  final int row;

  /// 그리드 열(0~2).
  final int col;

  const BoardCategory({
    required this.id,
    required this.labelEn,
    required this.row,
    required this.col,
  });
}

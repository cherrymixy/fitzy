/// 하루 기록 — 그날 뽑은 무드와 9칸 보드 상태.
///
/// 코인을 넣어 무드를 확정한 순간 생성되고, 그날의 9칸을 이미지로 채운다.
/// 자정 경계를 넘으면 [finalized]=true로 마감(이미지 추가/수정 불가).
class DayRecord {
  /// 보드 9칸 수.
  static const int cellCount = 9;

  /// 날짜 키(yyyy-MM-dd).
  final String dateKey;

  /// 그날 뽑은 무드 id(MoodFit.id).
  final String moodFitId;

  /// 보드 제목(= 무드명, 편집 가능). 마감 후에도 편집 허용.
  String moodTitle;

  /// categoryId -> imagePath(없으면 null). 9개 키.
  final Map<String, String?> cells;

  /// 즐겨찾기. 마감 후에도 토글 허용.
  bool isFavorite;

  /// 자정 마감 여부(true면 이미지 추가/수정 불가).
  bool finalized;

  final DateTime createdAt;
  DateTime updatedAt;

  DayRecord({
    required this.dateKey,
    required this.moodFitId,
    required this.moodTitle,
    required this.cells,
    this.isFavorite = false,
    this.finalized = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 채워진 칸 수(null 아닌 셀).
  int get filledCount =>
      cells.values.where((path) => path != null).length;

  /// 완성 여부(9/9).
  bool get isComplete => filledCount == cellCount;
}

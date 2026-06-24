/// 로컬 시각을 'yyyy-MM-dd' 날짜 키로 변환.
///
/// 코인 일일 리셋과 DayRecord의 공용 기준점. [now]를 주입받아 자정 경계를
/// 단위테스트할 수 있게 한다(앱에선 DateTime.now()).
String dateKeyOf(DateTime now) {
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// 공지사항 콘텐츠 (data/ 관리). 서버 없는 경로 A에서는 정적 목록.
class Notice {
  final String date;
  final String title;
  final String body;
  const Notice({required this.date, required this.title, required this.body});
}

const List<Notice> kNotices = [
  Notice(
    date: '2026.06.24',
    title: 'FITZY 베타를 시작했어요 🎉',
    body: '추구미를 도달 가능미로 — 코인으로 무드를 뽑고 9칸 보드를 채워 '
        '캘린더에 기록해 보세요. 베타 기간 동안의 데이터는 기기 내에만 저장됩니다.',
  ),
  Notice(
    date: '2026.06.22',
    title: '로그인/회원가입 화면이 새로워졌어요',
    body: '온보딩과 회원가입 흐름을 단계별로 정리했어요. 마이페이지에서 닉네임과 '
        '프로필 이미지를 언제든 바꿀 수 있습니다.',
  ),
  Notice(
    date: '2026.06.20',
    title: '안드로이드 APK · 웹 체험 안내',
    body: '웹(설치 없이)과 안드로이드 APK로도 FITZY를 사용할 수 있어요. '
        '웹은 데모용으로 일부 기능이 제한됩니다.',
  ),
];

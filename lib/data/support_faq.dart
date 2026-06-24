/// 고객센터 콘텐츠 (data/ 관리). FAQ + 문의 메일.
class FaqItem {
  final String q;
  final String a;
  const FaqItem({required this.q, required this.a});
}

/// 문의 메일 주소 — 실제 운영 주소로 교체 필요(플레이스홀더).
const String kSupportEmail = 'fitzy.help@example.com';

const List<FaqItem> kFaq = [
  FaqItem(
    q: '코인은 언제 받나요?',
    a: '하루에 한 번, 자정이 지나면 새 코인이 지급돼요. 코인을 넣으면 오늘의 '
        '추구미를 한 번 뽑을 수 있습니다.',
  ),
  FaqItem(
    q: '뽑은 무드를 다시 바꿀 수 있나요?',
    a: '하루 한 번 뽑기 규칙이라 같은 날에는 다시 뽑을 수 없어요. 내일 새 코인으로 '
        '다시 시도할 수 있습니다.',
  ),
  FaqItem(
    q: '보드는 어떻게 완성하나요?',
    a: '9칸을 모두 사진으로 채우면 완성돼요. 자정 마감 시 완성된 보드만 캘린더에 '
        '기록으로 남습니다.',
  ),
  FaqItem(
    q: '패스워드를 잊어버렸어요.',
    a: '패스워드는 복구할 수 없어요(안전하게 해시로 저장돼요). 로그인 화면의 '
        '"ID/패스워드를 까먹으셨나요?"에서 새 패스워드로 재설정할 수 있습니다.',
  ),
  FaqItem(
    q: '데이터는 어디에 저장되나요?',
    a: '현재 버전은 모든 데이터를 기기 안에만 저장하고 외부로 전송하지 않아요. '
        '앱을 삭제하면 기록도 함께 사라집니다.',
  ),
];

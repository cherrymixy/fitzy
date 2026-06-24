# CLAUDE.md — FITZY

## 이 프로젝트
코인1로 9무드 중 뽑기(Select) → 그 무드의 9칸 보드를 촬영/갤러리로 채우기(Board) → 자정 마감 →
완성 보드만 캘린더 기록. 4탭(Select/Board/Calendar/My)+온보딩+(최소)회원가입. Flutter+Dart.
태그라인: 추구미를 도달 가능미로.

## 스택 (고정)
- Flutter / Dart · Provider · shared_preferences · image_picker · path_provider · Navigator
- 계정 경로: [A 로컬 / B Firebase] — 데이터는 repositories/ 인터페이스로 추상화
- 비주얼: Codex가 만든 HTML/CSS를 theme 토큰 기반 Flutter 위젯으로 '번역'

## 폴더
lib/ main.dart  models/  services/  repositories/  providers/  screens/  widgets/  theme/  data/
assets/ fonts/  images/  data/

## 9무드 / 9카테고리
무드: 러블리·캐주얼·스포티·스트릿·미니멀·빈티지·프레피·시크·청순 (data/)
보드: Food·Outfit·Color / Hobby·Place·Activity / Music·Work·Drink (data/)

## 작업 규칙
1. 요청 범위만. 다른 화면/파일 임의 수정·미리 만들기 금지.
2. [디자인 패스] models/services/repositories/providers/data 수정 금지. theme/screens/widgets만.
3. [로직 패스] 회색박스로 동작만, 비주얼 신경 X.
4. 무거운 단계(스캐폴드·계정·코인/뽑기·Board·Codex 번역)는 코드 전 계획부터, 승인 대기.
5. 한 번에 하나. 끝나면 flutter run/test 후 git commit.
6. 픽셀·색·간격 추측 금지. 정확한 값/HTML 스펙대로. 측정 스크립트 금지.
7. 콘텐츠(무드·카테고리·문구)는 data/에서. 하드코딩 금지.
8. 색·타이포는 theme/ 토큰. 위젯 hex 하드코딩 금지.
9. 사용자 이미지는 image_store가 documents로 복사한 경로만 저장.
10. Codex HTML/CSS '번역' 시 로직(provider 데이터 흐름) 절대 변경 X, 자리만 연결.

## 빌드 순서
1 스캐폴드 → 2 모델·콘텐츠 → 3 저장·상태·이미지(Repository) → 4 계정·온보딩 → 5 코인·Select 뽑기
→ 6 Board·마감 → 7 회색박스 화면 → 8 통합테스트(동결 v0.1)
--- 디자인 ---
10 토큰 → 11 폰트·에셋 → 12 Codex HTML/CSS 번역 → 13 폴리시 → 14 연출 → 15 마감
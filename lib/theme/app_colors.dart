import 'package:flutter/painting.dart';

/// FITZY 색 토큰 — Figma에서 직접 추출(추측 없음).
/// 화이트 베이스 · 클린 미니멀 모노톤.
class AppColors {
  const AppColors._();

  /// 배경 (bg-white).
  static const Color background = Color(0xFFFFFFFF);

  /// 카드/셀 배경 (Board 9칸 셀 bg-[#f8f8f8]).
  static const Color card = Color(0xFFF8F8F8);

  /// 코인 칩 배경 (bg-[#f3f3f3]).
  static const Color coin = Color(0xFFF3F3F3);

  /// 본문/타이틀 텍스트 (text-[#3c3c3c]).
  static const Color text = Color(0xFF3C3C3C);

  /// 서브텍스트 — 날짜·카테고리·플레이스홀더 (text-[#b7b7b7]).
  static const Color subText = Color(0xFFB7B7B7);

  /// 강조 — 선택된 탭/액티브 (bg-[#454545]).
  static const Color accent = Color(0xFF454545);

  /// 보더 — 카드/버튼 (border-[#eee], CSS --line).
  static const Color border = Color(0xFFEEEEEE);

  /// 비활성 — 네비 비활성 아이콘 (CSS --muted #848484).
  static const Color muted = Color(0xFF848484);

  /// 옅은 보더 — 키패드/트레이 디테일 (#dddddd).
  static const Color lineSoft = Color(0xFFDDDDDD);

  /// 썸네일 플레이스홀더 — 캘린더 기록 마크 (#d9d9d9).
  static const Color thumbPlaceholder = Color(0xFFD9D9D9);

  /// 프로필 편집 버튼 배경 — 어두운 원형 (#383838).
  static const Color darkButton = Color(0xFF383838);

  /// 굵은 구분선 (My 섹션 divider #f4f4f4).
  static const Color dividerSoft = Color(0xFFF4F4F4);

  /// Figma 변수 "Labels/Primary" — 강한 텍스트/아이콘.
  static const Color labelPrimary = Color(0xFF000000);
}

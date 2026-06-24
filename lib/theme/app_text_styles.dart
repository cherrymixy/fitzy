import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// 한글 글리프 누락 시 폴백(iOS 한글 시스템 폰트). Pretendard가 한글 전체를
/// 커버하지만 안전망으로 둔다.
const List<String> _koFallback = <String>['Apple SD Gothic Neo'];

/// 텍스트 스타일 토큰 — Figma 추출. family는 Pretendard로 통일(한글·영문·워드마크).
/// letterSpacing은 Figma 0.8%를 해당 크기 px로 환산(예: 12px → 0.096).
class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Pretendard';

  /// 워드마크 — Figma는 logo.svg 이미지. 텍스트 대체용(Bold).
  static const TextStyle wordmark = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 타이틀 (Figma "Title 2": Bold 24 / 1.2 / 0). 보드 제목 등.
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 카테고리 (Figma "Label 6": Medium 12 / 1.4 / 0.8%). 셀 라벨.
  static const TextStyle category = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.096,
    color: AppColors.subText,
  );

  /// 캡션 — 날짜·N images (Medium 12 / 1.4 / 0.8%).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.096,
    color: AppColors.subText,
  );

  /// 탭 라벨·코인 숫자 (Medium 14 / 0).
  static const TextStyle tab = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 아이브로우 "Pick Your Fit" (Regular 12 / 1.4 / 0).
  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 자판기 패널 라벨 INSERT/RETURN (Medium 10 / 1.25 / 0.08).
  static const TextStyle panelTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.08,
    color: AppColors.text,
  );

  /// 키패드 키 (Medium 11 / 1).
  static const TextStyle keyLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 자판기 슬롯 라벨 A1~C3 (Bold 13 / 1, 흰 배경 위).
  static const TextStyle fitLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 캘린더 월 (SemiBold 16 / 1 / -0.16).
  static const TextStyle calendarMonth = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.16,
    color: AppColors.text,
  );

  /// 요일·날짜 셀 (Medium 11.4 / 1 / -0.114).
  static const TextStyle weekday = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 11.4,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.114,
    color: AppColors.text,
  );

  /// 월 통계 라벨 (Medium 11 / 1.4 / 0.088).
  static const TextStyle summaryLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.088,
    color: AppColors.text,
  );

  /// 월 통계 값 (SemiBold 21 / 0.82 / 0.168).
  static const TextStyle summaryValue = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 0.82,
    letterSpacing: 0.168,
    color: AppColors.text,
  );

  /// 월 통계 단위 (Medium 11 / 1).
  static const TextStyle summaryUnit = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// My 메뉴 행 (Medium 16 / 1.2).
  static const TextStyle menuRow = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// My 태그 칩 (Medium 12).
  static const TextStyle tag = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: _koFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.text,
  );
}

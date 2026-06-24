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
}

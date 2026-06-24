import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// 텍스트 스타일 토큰 — Figma 추출.
///
/// fontFamily는 STEP 11에서 연결(현재 미지정).
/// Figma 기준: 본문/타이틀/카테고리는 Pretendard, 탭/코인은 Spoqa Han Sans Neo.
/// letterSpacing은 Figma 0.8%를 해당 크기의 px로 환산(예: 12px → 0.096).
class AppTextStyles {
  const AppTextStyles._();

  /// 워드마크 — Figma에서는 logo.svg 이미지. 텍스트 대체용(Title 2 기준 Bold).
  static const TextStyle wordmark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 타이틀 (Figma "Title 2": Pretendard Bold 24 / 1.2 / 0). 보드 제목 등.
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.text,
  );

  /// 카테고리 (Figma "Label 6": Pretendard Medium 12 / 1.4 / 0.8%). 셀 라벨.
  static const TextStyle category = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.096,
    color: AppColors.subText,
  );

  /// 캡션 — 날짜·N images (Pretendard Medium 12 / 1.4 / 0.8%).
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.096,
    color: AppColors.subText,
  );

  /// 탭 라벨 (Spoqa Han Sans Neo Medium 14 / 0). 코인 숫자도 동일.
  static const TextStyle tab = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.text,
  );
}

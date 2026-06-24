import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// FITZY ThemeData — 토큰을 ThemeData로 묶음. 화이트 베이스·클린 미니멀.
/// 위젯은 하드코딩 대신 이 테마/토큰을 참조한다(개별 위젯 적용은 STEP 12).
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent).copyWith(
        surface: AppColors.background,
        onSurface: AppColors.text,
        primary: AppColors.accent,
        onPrimary: AppColors.background,
        secondary: AppColors.accent,
        // fromSeed가 만든 비-모노톤 틴트 제거 — 컨테이너는 중립 회색 고정.
        secondaryContainer: AppColors.card,
        onSecondaryContainer: AppColors.text,
        surfaceContainerHighest: AppColors.card,
      ),
      dividerColor: AppColors.border,
      textTheme: base.textTheme.copyWith(
        titleLarge: AppTextStyles.title,
        bodyMedium: const TextStyle(color: AppColors.text),
        labelSmall: AppTextStyles.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

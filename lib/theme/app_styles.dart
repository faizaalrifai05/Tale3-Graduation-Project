import 'package:flutter/material.dart';

class AppStyles {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF8B1A2B);
  static const Color darkMaroon = Color(0xFF5C0A1A);

  // ── Background Colors ─────────────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color cardBackgroundColor = Color(0xFFF5F5F5);
  static const Color highlightBackgroundColor = Color(0xFFFDF2F4);

  // ── Border & Dividers ──────────────────────────────────────────────────────
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color roleBorderColor = Color(0xFFF5D5DB);

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDeep = Color(0xFF424242);

  // ── Input Colors ──────────────────────────────────────────────────────────
  static const Color inputHintColor = Color(0xFFBDBDBD);
  static const Color inputFillColor = Color(0xFFF9F9F9);

  // ── Extra Element Colors ──────────────────────────────────────────────────
  static const Color starRatingColor = Color(0xFFFFC107);
  static const Color goldStar = Color(0xFFFFD700);
  static const Color progressGold = Color(0xFFE8C06A);
  static const Color errorColor = Colors.red;
  static const Color errorLightBg = Color(0xFFFFF0F0);

  // ── Success Colors ────────────────────────────────────────────────────────
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successLightBg = Color(0xFFE8F5E9);
  static const Color successDarkText = Color(0xFF2E7D32);
  static const Color successBorder = Color(0xFFA5D6A7);
  static const Color successBgVerified = Color(0xFFF0FBF1);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color pendingColor = Color(0xFFFF9800);
  static const Color deepOrange = Color(0xFFE65100);
  static const Color notificationDot = Color(0xFFFF6B6B);
  static const Color cameraButtonColor = Color(0xFFFF4D4D);

  // ── Star Rating Colors ────────────────────────────────────────────────────
  static const Color starRatingLightBg = Color(0xFFFFF8E1);
  static const Color starRatingDarkText = Color(0xFFF57F17);

  // ── Gradient ──────────────────────────────────────────────────────────────
  static const Color gradientDeepColor = Color(0xFF3D0611);

  // ── On-Primary (icons / text on dark brand surfaces) ─────────────────────
  static const Color onPrimary = Colors.white;

  // ── Neutral / Dashboard ───────────────────────────────────────────────────
  static const Color neutralLight = Color(0xFFEDF1F5);

  // ── Google Brand Colors (Sign-In button only) ─────────────────────────────
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleText = Color(0xFF3C4043);
  static const Color googleBorder = Color(0xFFDDDDDD);

  // ══════════════════════════════════════════════════════════════════════════
  //  DARK THEME COLOR PALETTE
  //  Derived from light palette: darker / muted / inverted counterparts.
  // ══════════════════════════════════════════════════════════════════════════
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardBackgroundColor = Color(0xFF2A2A2A);
  static const Color darkHighlightBackgroundColor = Color(0xFF2D1A1D);
  static const Color darkBorderColor = Color(0xFF3A3A3A);
  static const Color darkDividerColor = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF787878);
  static const Color darkInputHintColor = Color(0xFF555555);
  static const Color darkInputFillColor = Color(0xFF252525);
  static const Color darkNeutralLight = Color(0xFF2A3038);
  static const Color darkErrorLightBg = Color(0xFF2D1212);

  // ══════════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: onPrimary,
          secondary: darkMaroon,
          surface: surfaceColor,
          onSurface: textPrimary,
          error: errorColor,
          outline: borderColor,
        ),
        scaffoldBackgroundColor: surfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
          centerTitle: true,
        ),
        dividerColor: dividerColor,
        cardColor: surfaceColor,
        useMaterial3: true,
        fontFamily: 'Roboto',
      );

  // ══════════════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme => ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          onPrimary: onPrimary,
          secondary: darkMaroon,
          surface: darkSurfaceColor,
          onSurface: darkTextPrimary,
          error: errorColor,
          outline: darkBorderColor,
        ),
        scaffoldBackgroundColor: darkSurfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurfaceColor,
          elevation: 0,
          iconTheme: IconThemeData(color: darkTextPrimary),
          titleTextStyle: TextStyle(
            color: darkTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
          centerTitle: true,
        ),
        dividerColor: darkDividerColor,
        cardColor: darkSurfaceColor,
        useMaterial3: true,
        fontFamily: 'Roboto',
      );
}

// ════════════════════════════════════════════════════════════════════════════
//  BuildContext extension — theme-aware color accessor
//  Usage: context.colors.textPrimary, context.colors.surfaceColor, etc.
// ════════════════════════════════════════════════════════════════════════════

extension AppStylesContext on BuildContext {
  AppColorProxy get colors => AppColorProxy(this);
}

class AppColorProxy {
  final BuildContext _ctx;
  AppColorProxy(this._ctx);

  bool get _isDark => Theme.of(_ctx).brightness == Brightness.dark;

  // Brand — always the same regardless of mode
  Color get primaryColor => AppStyles.primaryColor;
  Color get darkMaroon => AppStyles.darkMaroon;
  Color get onPrimary => AppStyles.onPrimary;
  Color get gradientDeepColor => AppStyles.gradientDeepColor;

  // Backgrounds
  Color get backgroundColor =>
      _isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor;
  Color get surfaceColor =>
      _isDark ? AppStyles.darkSurfaceColor : AppStyles.surfaceColor;
  Color get cardBackgroundColor =>
      _isDark ? AppStyles.darkCardBackgroundColor : AppStyles.cardBackgroundColor;
  Color get highlightBackgroundColor =>
      _isDark ? AppStyles.darkHighlightBackgroundColor : AppStyles.highlightBackgroundColor;

  // Borders
  Color get borderColor =>
      _isDark ? AppStyles.darkBorderColor : AppStyles.borderColor;
  Color get dividerColor =>
      _isDark ? AppStyles.darkDividerColor : AppStyles.dividerColor;
  Color get roleBorderColor =>
      _isDark ? AppStyles.darkBorderColor : AppStyles.roleBorderColor;

  // Text
  Color get textPrimary =>
      _isDark ? AppStyles.darkTextPrimary : AppStyles.textPrimary;
  Color get textSecondary =>
      _isDark ? AppStyles.darkTextSecondary : AppStyles.textSecondary;
  Color get textTertiary =>
      _isDark ? AppStyles.darkTextTertiary : AppStyles.textTertiary;
  Color get textDeep =>
      _isDark ? AppStyles.darkTextPrimary : AppStyles.textDeep;

  // Input
  Color get inputHintColor =>
      _isDark ? AppStyles.darkInputHintColor : AppStyles.inputHintColor;
  Color get inputFillColor =>
      _isDark ? AppStyles.darkInputFillColor : AppStyles.inputFillColor;

  // Neutral
  Color get neutralLight =>
      _isDark ? AppStyles.darkNeutralLight : AppStyles.neutralLight;

  // Error
  Color get errorLightBg =>
      _isDark ? AppStyles.darkErrorLightBg : AppStyles.errorLightBg;

  // Fixed semantic colors (same in both modes)
  Color get starRatingColor => AppStyles.starRatingColor;
  Color get goldStar => AppStyles.goldStar;
  Color get progressGold => AppStyles.progressGold;
  Color get errorColor => AppStyles.errorColor;
  Color get successColor => AppStyles.successColor;
  Color get successLightBg => AppStyles.successLightBg;
  Color get successDarkText => AppStyles.successDarkText;
  Color get successBorder => AppStyles.successBorder;
  Color get successBgVerified => AppStyles.successBgVerified;
  Color get pendingColor => AppStyles.pendingColor;
  Color get deepOrange => AppStyles.deepOrange;
  Color get notificationDot => AppStyles.notificationDot;
  Color get cameraButtonColor => AppStyles.cameraButtonColor;
  Color get starRatingLightBg => AppStyles.starRatingLightBg;
  Color get starRatingDarkText => AppStyles.starRatingDarkText;
  Color get googleBorder => AppStyles.googleBorder;
}

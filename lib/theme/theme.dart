import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF5252);
  static const Color primaryVariant = Color(0xFFE75152);
  static const Color accent = Color(0xFFF0525A);
  static const Color background = Color(0xFFFFFFFF);
  static const Color onPrimary = Colors.white;
  static const Color textDark = Color(0xFF333333);
  static const Color focusBorder = Color(0xFFF9E3A8); // Jaune pastel
}

final ThemeData flixPickTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  fontFamily: 'Poppins',

  // Curseur rouge dans les champs de texte
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primary,
    selectionColor: AppColors.primary.withOpacity(0.4),
    selectionHandleColor: AppColors.primary,
  ),

  // Palette principale
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.background,
    onPrimary: AppColors.onPrimary,
    brightness: Brightness.light,
  ),

  // Style de texte général
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: AppColors.textDark,
      fontSize: 14,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),

  // Boutons principaux
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),

  // Boutons de lien comme "Sign up"
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      textStyle: const TextStyle(
        decoration: TextDecoration.underline,
      ),
    ),
  ),

  // Champs de texte
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.focusBorder,
        width: 2,
      ),
    ),
    labelStyle: const TextStyle(color: AppColors.textDark),
    floatingLabelStyle: const TextStyle(color: AppColors.textDark),
    hintStyle: const TextStyle(color: AppColors.textDark),
  ),

  // Style du DatePicker
  datePickerTheme: DatePickerThemeData(
    backgroundColor: AppColors.background,
    headerBackgroundColor: AppColors.background,
    dayOverlayColor: MaterialStateProperty.all(Colors.transparent),
    dayForegroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.onPrimary;
      }
      return AppColors.textDark;
    }),
    dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    yearBackgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    yearForegroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.onPrimary;
      }
      return AppColors.textDark;
    }),
    todayForegroundColor: MaterialStateProperty.all(AppColors.primary),
    todayBackgroundColor: MaterialStateProperty.all(Colors.transparent),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
    ),
  ),
);

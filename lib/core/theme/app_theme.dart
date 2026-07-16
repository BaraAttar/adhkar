import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ألوان الثيم المستخرجة من ملف الـ HTML
class AppColors {
  // ألوان الوضع الفاتح (Light Mode)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF0D9488); // الفيروزي (Teal)
  static const Color lightPrimaryLight = Color(0xFFCCFBF1);
  static const Color lightSuccess = Color(0xFFD97706); // الذهبي (Amber)
  static const Color lightSuccessLight = Color(0xFFFEF3C7);
  static const Color lightTextDark = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFF1F5F9);
  static const Color lightSupportBg = Color(0xFFF8FAFC);

  // ألوان الوضع الداكن (Dark Mode)
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFF14B8A6);
  static const Color darkPrimaryLight = Color(0xFF115E59);
  static const Color darkSuccess = Color(0xFFD97706);
  static const Color darkSuccessLight = Color(
    0xFFFEF3C7,
  ); // يمكن الحفاظ عليها أو تعديلها
  static const Color darkTextDark = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkSupportBg = Color(0xFF1E293B);
}

class AppTheme {
  // إعدادات الثيم الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      cardColor: AppColors.lightCardBg,
      dividerColor: AppColors.lightBorder,

      // تطبيق خط Tajawal على كافة النصوص
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        bodyLarge: TextStyle(color: AppColors.lightTextDark),
        bodyMedium: TextStyle(color: AppColors.lightTextMuted),
      ),

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSuccess,
        surface: AppColors.lightCardBg,
      ),

      // ثيم شريط التنقل السفلي (Bottom Navigation)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightCardBg,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightTextMuted,
        elevation: 8,

        // تطبيق خط Tajawal صراحةً على النصوص النشطة وغير النشطة
        selectedLabelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),

      // ثيم الأزرار الكبيرة (الشبيهة بالزر التفاعلي المريح في الـ HTML)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // إعدادات الثيم الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      cardColor: AppColors.darkCardBg,
      dividerColor: AppColors.darkBorder,

      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        bodyLarge: TextStyle(color: AppColors.darkTextDark),
        bodyMedium: TextStyle(color: AppColors.darkTextMuted),
      ),

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSuccess,
        surface: AppColors.darkCardBg,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCardBg,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextMuted,
        elevation: 8,

        // تطبيق خط Tajawal صراحةً
        selectedLabelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

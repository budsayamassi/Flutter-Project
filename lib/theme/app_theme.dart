import 'package:flutter/material.dart';

// ---------- สีหลักของแอป (โทนฟ้า-ขาว คลีน สบายตา) ----------
const Color kPrimary = Color(0xFF4F6DF5); // ฟ้าอมม่วงอ่อน สีหลัก
const Color kPrimaryLight = Color(0xFF7B93FA); // ใช้ทำ Gradient
const Color kGreen = Color(0xFF22C55E);
const Color kOrange = Color(0xFFF59E0B);
const Color kRed = Color(0xFFEF4444);
const Color kPurple = Color(0xFF8B5CF6);
const Color kTeal = Color(0xFF14B8A6);
const Color kGrey = Color(0xFF8A94A6); // ตัวหนังสือรอง

// สีพื้นหลัง
const Color kBgLight = Color(0xFFF5F7FB);
const Color kBgDark = Color(0xFF0F1115);
const Color kCardDark = Color(0xFF1A1D24);
const Color kTextDark = Color(0xFF1E2330);

// Gradient สำหรับการ์ดหัวข้อ
const LinearGradient kHeaderGradient = LinearGradient(
  colors: [kPrimary, kPrimaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: kBgLight,
        card: Colors.white,
        text: kTextDark,
        border: const Color(0xFFE4E8F1),
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: kBgDark,
        card: kCardDark,
        text: Colors.white,
        border: const Color(0xFF2A2E38),
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color text,
    required Color border,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: brightness,
        primary: kPrimary,
        surface: card,
        onSurface: text,
      ),
      scaffoldBackgroundColor: background,

      // แถบด้านบน
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: text),
      ),

      // การ์ด: มุมมน + เงาบางๆ
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border),
        ),
      ),

      // ช่องกรอกข้อมูล
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: const TextStyle(color: kGrey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),

      // ปุ่มหลัก
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: kPrimary),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // แถบเมนูด้านล่าง
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: kPrimary.withValues(alpha: 0.12),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),

      dividerColor: border,
    );
  }
}

import 'package:flutter/material.dart';

// สีหลักของแอป (โทนขาว-ฟ้า สไตล์ iPhone)
const Color kPrimary = Color(0xFF007AFF);
const Color kGreen = Color(0xFF34C759);
const Color kOrange = Color(0xFFFF9500);
const Color kRed = Color(0xFFFF3B30);
const Color kPurple = Color(0xFFAF52DE);
const Color kGrey = Color(0xFF8E8E93);

class AppTheme {
  // ธีมสว่าง
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: const Color(0xFFF2F2F7),
        card: Colors.white,
      );

  // ธีมมืด
  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: Colors.black,
        card: const Color(0xFF1C1C1E),
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color card,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: brightness,
        primary: kPrimary,
        surface: card,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
    );
  }
}

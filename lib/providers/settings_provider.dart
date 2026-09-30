import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// เก็บการตั้งค่า ธีมมืด/สว่าง และ ภาษาไทย/อังกฤษ
// - ใช้ Provider (with ChangeNotifier) เพื่อให้ทุกหน้าเปลี่ยนตามทันที (บทที่ 7)
// - บันทึกลง SharedPreferences เพื่อให้ค่ายังอยู่หลังปิดแอป (บทที่ 9)
class SettingsProvider with ChangeNotifier {
  bool _isDark = false;
  bool _isThai = true;

  bool get isDark => _isDark;
  bool get isThai => _isThai;

  // เลือกข้อความตามภาษาปัจจุบัน เช่น settings.tr('บันทึก', 'Save')
  String tr(String thai, String english) {
    return _isThai ? thai : english;
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    _isThai = prefs.getBool('isThai') ?? true;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
  }

  Future<void> setThai(bool value) async {
    _isThai = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isThai', value);
  }
}

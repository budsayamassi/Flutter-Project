import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

// แสดงแถบข้อความด้านล่างจอ (SnackBar)
void showMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? kRed : const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// กล่องยืนยัน Yes/No (AlertDialog) — คืนค่า true ถ้ากดยืนยัน
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String yesText,
  required String noText,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // ต้องกดปุ่มเพื่อปิด
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(noText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(yesText, style: const TextStyle(color: kRed)),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

// จัดรูปแบบวันที่ เช่น 30 ก.ย. 2026 · 18:00
String formatDateTime(DateTime date, bool isThai) {
  return DateFormat('d MMM yyyy · HH:mm', isThai ? 'th' : 'en').format(date);
}

String formatDate(DateTime date, bool isThai) {
  return DateFormat('d MMMM yyyy', isThai ? 'th' : 'en').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

// สีตามระดับความเร่งด่วน
Color priorityColor(int level) {
  if (level == 3) return kRed;
  if (level == 2) return kOrange;
  return kGreen;
}

// สีประจำหมวดหมู่
Color categoryColor(String category) {
  if (category == 'work') return kPrimary;
  if (category == 'study') return kOrange;
  if (category == 'health') return kGreen;
  if (category == 'personal') return kPurple;
  return kGrey;
}

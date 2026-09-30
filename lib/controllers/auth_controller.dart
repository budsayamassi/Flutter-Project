import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

// สะพานเชื่อมระหว่างหน้าจอ Login/Register กับ Service
// คืนค่า null = สำเร็จ, คืนค่าเป็นข้อความ = เกิดข้อผิดพลาด (ให้หน้าจอนำไปแสดง)
class AuthController {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool get isLoggedIn => _authService.currentUser != null;

  Future<String?> login(String email, String password, bool isThai) async {
    try {
      await _authService.login(email.trim(), password);

      // บัญชีที่สมัครผ่าน Firebase Console จะยังไม่มีโปรไฟล์ → สร้างให้
      final profile = await _userService.getProfile();
      if (profile == null) {
        await _userService.createProfile(email.split('@').first, email.trim());
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorText(e.code, isThai);
    }
  }

  Future<String?> register(String name, String email, String password, bool isThai) async {
    try {
      await _authService.register(name.trim(), email.trim(), password);
      await _userService.createProfile(name.trim(), email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorText(e.code, isThai);
    }
  }
  Future<String?> changePassword(String current, String newPassword, bool isThai) async {
    try {
      await _authService.changePassword(current, newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorText(e.code, isThai);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  // แปลงรหัส Error ของ Firebase เป็นข้อความที่อ่านเข้าใจ
  String _errorText(String code, bool isThai) {
    if (code == 'invalid-credential' || code == 'wrong-password' || code == 'user-not-found') {
      return isThai ? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' : 'Incorrect email or password';
    } else if (code == 'email-already-in-use') {
      return isThai ? 'อีเมลนี้ถูกใช้สมัครแล้ว' : 'This email is already registered';
    } else if (code == 'weak-password') {
      return isThai ? 'รหัสผ่านง่ายเกินไป' : 'Password is too weak';
    } else if (code == 'invalid-email') {
      return isThai ? 'รูปแบบอีเมลไม่ถูกต้อง' : 'Invalid email address';
    } else if (code == 'network-request-failed') {
      return isThai ? 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต' : 'No internet connection';
    } else if (code == 'too-many-requests') {
      return isThai ? 'ลองหลายครั้งเกินไป กรุณารอสักครู่' : 'Too many attempts, please wait';
    }
    return isThai ? 'เกิดข้อผิดพลาด ($code)' : 'Something went wrong ($code)';
  }
}

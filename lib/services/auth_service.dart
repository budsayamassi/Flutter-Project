import 'package:firebase_auth/firebase_auth.dart';

// ติดต่อ Firebase Authentication (บทที่ 11)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<User?> register(String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user?.updateDisplayName(name);
    return result.user;
  }

  // Firebase บังคับให้ยืนยันรหัสผ่านเดิมก่อนเปลี่ยนรหัสใหม่
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

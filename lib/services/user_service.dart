import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

// จัดการข้อมูลโปรไฟล์ใน Cloud Firestore (users/{uid})
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid);
  }

  // อ่านโปรไฟล์แบบ Realtime (ใช้กับ StreamBuilder)
  Stream<UserProfile?> getProfileStream() {
    return _userDoc().snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(snapshot.data()!);
    });
  }

  // อ่านโปรไฟล์ครั้งเดียว
  Future<UserProfile?> getProfile() async {
    final snapshot = await _userDoc().get();
    if (!snapshot.exists) return null;
    return UserProfile.fromMap(snapshot.data()!);
  }

  Future<void> createProfile(String name, String email) async {
    final profile = UserProfile(name: name, email: email);
    await _userDoc().set(profile.toMap());
  }

  Future<void> updateName(String name) async {
    await _userDoc().update({'name': name});
  }

  Future<void> updateStats(UserProfile profile) async {
    await _userDoc().update({
      'xp': profile.xp,
      'streak': profile.streak,
      'lastActiveDate': profile.lastActiveDate,
      'totalDone': profile.totalDone,
    });
  }
}

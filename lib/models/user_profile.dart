// ข้อมูลโปรไฟล์ของผู้ใช้ + ค่า XP / Level / Streak
// เก็บใน Firestore ที่ users/{uid}
class UserProfile {
  String name;
  String email;
  int xp;
  int streak;
  String lastActiveDate; // วันล่าสุดที่ทำงานเสร็จ เช่น 2026-09-30
  int totalDone;

  UserProfile({
    required this.name,
    required this.email,
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate = '',
    this.totalDone = 0,
  });

  // ทุกๆ 100 XP = ขึ้น 1 Level
  int get level => xp ~/ 100 + 1;
  int get xpInLevel => xp % 100;

  // ต้นไม้ประจำตัว โตขึ้นตาม Level
  String get plantEmoji {
    if (level >= 10) return '🌳';
    if (level >= 6) return '🪴';
    if (level >= 3) return '🌿';
    return '🌱';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'xp': xp,
      'streak': streak,
      'lastActiveDate': lastActiveDate,
      'totalDone': totalDone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] ?? 'User',
      email: data['email'] ?? '',
      xp: data['xp'] ?? 0,
      streak: data['streak'] ?? 0,
      lastActiveDate: data['lastActiveDate'] ?? '',
      totalDone: data['totalDone'] ?? 0,
    );
  }
}

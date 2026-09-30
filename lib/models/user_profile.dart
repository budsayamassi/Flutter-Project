// ข้อมูลโปรไฟล์ของผู้ใช้ — เก็บใน Firestore ที่ users/{uid}
class UserProfile {
  String name;
  String email;

  UserProfile({required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'] ?? 'User',
      email: data['email'] ?? '',
    );
  }
}

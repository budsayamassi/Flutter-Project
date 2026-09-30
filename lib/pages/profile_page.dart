import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user_profile.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_helpers.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

// หน้าจอ 6: Profile — ข้อมูลผู้ใช้, แก้ไขข้อมูล, เปลี่ยนรหัสผ่าน, ภาษา, ธีม, ออกจากระบบ
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _profileController = ProfileController();
  final AuthController _authController = AuthController();
  late Stream<UserProfile?> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = _profileController.getProfileStream();
  }

  Future<void> _logout() async {
    final s = context.read<SettingsProvider>();
    final yes = await showConfirmDialog(
      context,
      title: s.tr('ออกจากระบบ?', 'Log out?'),
      message: s.tr('ต้องการออกจากระบบใช่หรือไม่', 'Do you want to log out?'),
      yesText: s.tr('ใช่', 'Yes'),
      noText: s.tr('ไม่', 'No'),
    );
    if (!yes) return;

    await _authController.logout();
    if (!mounted) return;

    // กลับไปหน้า Login และลบทุกหน้าออกจาก Stack (กดย้อนกลับไม่ได้)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(s.tr('โปรไฟล์', 'Profile'))),
      body: StreamBuilder<UserProfile?>(
        stream: _profileStream,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = profile?.name ?? 'User';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // ---------- การ์ดหัวข้อ: รูป + ชื่อ + อีเมล ----------
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: kHeaderGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 38, color: kPrimary, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text(profile?.email ?? '', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // ---------- บัญชี ----------
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: _iconBox(Icons.person, kPrimary),
                      title: Text(s.tr('แก้ไขข้อมูล', 'Edit profile')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfilePage(currentName: name)),
                        );
                      },
                    ),
                    ListTile(
                      leading: _iconBox(Icons.lock, kGrey),
                      title: Text(s.tr('เปลี่ยนรหัสผ่าน', 'Change password')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---------- การแสดงผล (บันทึกใน SharedPreferences) ----------
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: _iconBox(Icons.language, kGreen),
                      title: Text(s.tr('ภาษา', 'Language')),
                      trailing: DropdownButton<bool>(
                        value: s.isThai,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: true, child: Text('ไทย')),
                          DropdownMenuItem(value: false, child: Text('English')),
                        ],
                        onChanged: (value) {
                          if (value != null) context.read<SettingsProvider>().setThai(value);
                        },
                      ),
                    ),
                    SwitchListTile(
                      secondary: _iconBox(Icons.dark_mode, kPurple),
                      title: Text(s.tr('ธีมมืด', 'Dark mode')),
                      value: s.isDark,
                      onChanged: (value) => context.read<SettingsProvider>().setDark(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---------- ออกจากระบบ ----------
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kRed,
                  side: const BorderSide(color: kRed),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout),
                label: Text(s.tr('ออกจากระบบ', 'Log out')),
                onPressed: _logout,
              ),
            ],
          );
        },
      ),
    );
  }

  // ไอคอนในกล่องสีอ่อนมุมมน
  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

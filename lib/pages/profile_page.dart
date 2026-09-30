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
            padding: const EdgeInsets.all(16),
            children: [
              // ---------- รูป + ชื่อ ----------
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: kPrimary.withValues(alpha: 0.15),
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: kPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(name, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(profile?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(color: kGrey)),
              const SizedBox(height: 20),

              // ---------- สถิติ ----------
              if (profile != null)
                Row(
                  children: [
                    _statBox(profile.plantEmoji, 'Level ${profile.level}', '${profile.xp} XP'),
                    const SizedBox(width: 10),
                    _statBox('🔥', '${profile.streak}', s.tr('วันติดต่อกัน', 'day streak')),
                    const SizedBox(width: 10),
                    _statBox('✅', '${profile.totalDone}', s.tr('งานที่เสร็จ', 'completed')),
                  ],
                ),
              const SizedBox(height: 24),

              // ---------- บัญชี ----------
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: kPrimary),
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
                      leading: const Icon(Icons.lock, color: kGrey),
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
                      leading: const Icon(Icons.language, color: kGreen),
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
                      secondary: const Icon(Icons.dark_mode, color: kPurple),
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

  Widget _statBox(String emoji, String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12, color: kGrey)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/auth_controller.dart';
import '../widgets/app_logo.dart';
import 'login_page.dart';
import 'main_page.dart';

// หน้า Splash Screen พร้อม Animation (บทที่ 4)
// จากนั้นตรวจสอบว่าเคย Login ไว้หรือไม่ แล้วไปหน้าที่เหมาะสม
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // pushReplacement: แทนที่หน้า Splash ไม่ให้กดย้อนกลับมาได้
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _authController.isLoggedIn ? const MainPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const AppLogo(size: 100)
            .animate()
            .fadeIn(duration: 700.ms)
            .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
      ),
    );
  }
}

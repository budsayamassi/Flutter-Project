import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/ui_helpers.dart';
import 'main_page.dart';

// หน้าจอ 2: สมัครสมาชิก
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthController _authController = AuthController();
  bool _loading = false;

  Future<void> _register() async {
    final s = context.read<SettingsProvider>();
    if (!_formKey.currentState!.saveAndValidate()) {
      showMessage(context, s.tr('กรุณากรอกข้อมูลให้ถูกต้อง', 'Please check your information'), isError: true);
      return;
    }

    final data = _formKey.currentState!.value;
    setState(() => _loading = true);
    final error = await _authController.register(data['name'], data['email'], data['password'], s.isThai);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      showMessage(context, error, isError: true);
      return;
    }

    showMessage(context, s.tr('สมัครสมาชิกสำเร็จ', 'Account created'));
    // ไปหน้าหลัก และลบหน้า Login/Register ออกจาก Stack ทั้งหมด
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(size: 64),
                const SizedBox(height: 8),
                Text(
                  s.tr('สร้างบัญชีเพื่อเริ่มเควสแรกของคุณ', 'Create an account to start your first quest'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                FormBuilderTextField(
                  name: 'name',
                  decoration: InputDecoration(
                    hintText: s.tr('ชื่อผู้ใช้', 'Username'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: FormBuilderValidators.required(errorText: s.tr('กรุณากรอกชื่อ', 'Please enter name')),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'email',
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: s.tr('อีเมล', 'Email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: s.tr('กรุณากรอกอีเมล', 'Please enter email')),
                    FormBuilderValidators.email(errorText: s.tr('รูปแบบอีเมลไม่ถูกต้อง', 'Invalid email')),
                  ]),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: s.tr('รหัสผ่าน', 'Password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: s.tr('กรุณากรอกรหัสผ่าน', 'Please enter password')),
                    FormBuilderValidators.minLength(6,
                        errorText: s.tr('รหัสผ่านอย่างน้อย 6 ตัวอักษร', 'At least 6 characters')),
                  ]),
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'confirm',
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: s.tr('ยืนยันรหัสผ่าน', 'Confirm password'),
                    prefixIcon: const Icon(Icons.lock_reset),
                  ),
                  // ตรวจสอบว่าตรงกับช่องรหัสผ่านหรือไม่
                  validator: (value) {
                    final password = _formKey.currentState?.fields['password']?.value;
                    if (value == null || value.isEmpty) {
                      return s.tr('กรุณายืนยันรหัสผ่าน', 'Please confirm password');
                    }
                    if (value != password) {
                      return s.tr('รหัสผ่านไม่ตรงกัน', 'Passwords do not match');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(s.tr('สมัครสมาชิก', 'Sign up')),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.tr('มีบัญชีอยู่แล้ว? เข้าสู่ระบบ', 'Already have an account? Log in')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

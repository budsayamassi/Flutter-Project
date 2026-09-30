import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/ui_helpers.dart';
import 'forgot_password_page.dart';
import 'main_page.dart';
import 'register_page.dart';

// หน้าจอ 1: เข้าสู่ระบบ
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthController _authController = AuthController();
  bool _hidePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    final s = context.read<SettingsProvider>();

    // ตรวจสอบข้อมูลในฟอร์มก่อน ถ้าไม่ครบจะได้ false
    if (!_formKey.currentState!.saveAndValidate()) {
      showMessage(context, s.tr('กรุณากรอกข้อมูลให้ครบถ้วน', 'Please fill in all fields'), isError: true);
      return;
    }

    final email = _formKey.currentState!.value['email'];
    final password = _formKey.currentState!.value['password'];

    setState(() => _loading = true);
    final error = await _authController.login(email, password, s.isThai);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      showMessage(context, error, isError: true);
      return;
    }

    // Login สำเร็จ → ไปหน้าหลัก (ไม่ให้กดย้อนกลับมาหน้า Login)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 40),
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
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      hintText: s.tr('รหัสผ่าน', 'Password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      // ปุ่มดู/ซ่อนรหัสผ่าน
                      suffixIcon: IconButton(
                        icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: s.tr('กรุณากรอกรหัสผ่าน', 'Please enter password'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                        );
                      },
                      child: Text(s.tr('ลืมรหัสผ่าน?', 'Forgot password?')),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(s.tr('เข้าสู่ระบบ', 'Log in')),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.tr('ยังไม่มีบัญชี?', "Don't have an account?")),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        child: Text(s.tr('สมัครสมาชิก', 'Sign up')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_helpers.dart';

// หน้าลืมรหัสผ่าน: ส่งลิงก์ตั้งรหัสผ่านใหม่ไปที่อีเมล
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthController _authController = AuthController();
  bool _loading = false;

  Future<void> _send() async {
    final s = context.read<SettingsProvider>();
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _loading = true);
    final error = await _authController.resetPassword(_formKey.currentState!.value['email'], s.isThai);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      showMessage(context, error, isError: true);
      return;
    }
    showMessage(context, s.tr('ส่งลิงก์แล้ว กรุณาตรวจสอบอีเมล', 'Reset link sent, please check your email'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(s.tr('ลืมรหัสผ่าน', 'Forgot password'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_reset, size: 64, color: kPrimary),
              const SizedBox(height: 16),
              Text(
                s.tr('กรอกอีเมลที่ใช้สมัคร เราจะส่งลิงก์สำหรับตั้งรหัสผ่านใหม่ให้',
                    "Enter your email and we'll send you a link to reset your password"),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                child: Text(s.tr('ส่งลิงก์', 'Send link')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

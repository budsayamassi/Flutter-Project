import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../providers/settings_provider.dart';
import '../widgets/ui_helpers.dart';

// เปลี่ยนรหัสผ่าน (ต้องกรอกรหัสผ่านเดิมก่อน)
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthController _authController = AuthController();
  bool _loading = false;

  Future<void> _save() async {
    final s = context.read<SettingsProvider>();
    if (!_formKey.currentState!.saveAndValidate()) return;

    final data = _formKey.currentState!.value;
    setState(() => _loading = true);
    final error = await _authController.changePassword(data['current'], data['new'], s.isThai);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      showMessage(context, error, isError: true);
      return;
    }
    showMessage(context, s.tr('เปลี่ยนรหัสผ่านเรียบร้อย', 'Password changed'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(s.tr('เปลี่ยนรหัสผ่าน', 'Change password'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'current',
                obscureText: true,
                decoration: InputDecoration(
                  hintText: s.tr('รหัสผ่านปัจจุบัน', 'Current password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: FormBuilderValidators.required(errorText: s.tr('กรุณากรอกรหัสผ่าน', 'Required')),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'new',
                obscureText: true,
                decoration: InputDecoration(
                  hintText: s.tr('รหัสผ่านใหม่', 'New password'),
                  prefixIcon: const Icon(Icons.lock_reset),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: s.tr('กรุณากรอกรหัสผ่าน', 'Required')),
                  FormBuilderValidators.minLength(6,
                      errorText: s.tr('รหัสผ่านอย่างน้อย 6 ตัวอักษร', 'At least 6 characters')),
                ]),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'confirm',
                obscureText: true,
                decoration: InputDecoration(
                  hintText: s.tr('ยืนยันรหัสผ่านใหม่', 'Confirm new password'),
                  prefixIcon: const Icon(Icons.lock_reset),
                ),
                validator: (value) {
                  if (value != _formKey.currentState?.fields['new']?.value) {
                    return s.tr('รหัสผ่านไม่ตรงกัน', 'Passwords do not match');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: Text(s.tr('บันทึก', 'Save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

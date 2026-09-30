import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_controller.dart';
import '../providers/settings_provider.dart';
import '../widgets/ui_helpers.dart';

// แก้ไขชื่อผู้ใช้
class EditProfilePage extends StatefulWidget {
  final String currentName;
  const EditProfilePage({super.key, required this.currentName});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ProfileController _controller = ProfileController();

  Future<void> _save() async {
    final s = context.read<SettingsProvider>();
    if (!_formKey.currentState!.saveAndValidate()) return;

    await _controller.updateName(_formKey.currentState!.value['name']);
    if (!mounted) return;
    showMessage(context, s.tr('บันทึกข้อมูลแล้ว', 'Profile saved'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(s.tr('แก้ไขข้อมูล', 'Edit profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'name',
                initialValue: widget.currentName,
                decoration: InputDecoration(
                  labelText: s.tr('ชื่อผู้ใช้', 'Username'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: FormBuilderValidators.required(errorText: s.tr('กรุณากรอกชื่อ', 'Please enter name')),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: Text(s.tr('บันทึก', 'Save'))),
            ],
          ),
        ),
      ),
    );
  }
}

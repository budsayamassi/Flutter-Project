import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/ui_helpers.dart';

// หน้าจอ 5: เพิ่มงานใหม่ / แก้ไขงาน
// - ถ้าส่ง task เข้ามา = โหมดแก้ไข (ส่งข้อมูลไปหน้าใหม่ บทที่ 5)
// - ถ้าไม่ส่ง = เพิ่มงานใหม่
class TaskFormPage extends StatefulWidget {
  final TaskModel? task;
  final DateTime? initialDate;

  const TaskFormPage({super.key, this.task, this.initialDate});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TaskController _controller = TaskController();
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  // วันเริ่มต้น: วันที่เลือกมา (หรือวันนี้) เวลา 18:00
  DateTime _defaultDate() {
    final day = widget.initialDate ?? DateTime.now();
    return DateTime(day.year, day.month, day.day, 18, 0);
  }

  Future<void> _save() async {
    final s = context.read<SettingsProvider>();
    if (!_formKey.currentState!.saveAndValidate()) {
      showMessage(context, s.tr('กรุณากรอกข้อมูลให้ครบถ้วน', 'Please fill in all fields'), isError: true);
      return;
    }

    final data = _formKey.currentState!.value;
    final task = TaskModel(
      id: widget.task?.id ?? '',
      title: data['title'],
      description: data['description'] ?? '',
      category: data['category'],
      importance: data['importance'],
      dueDate: data['dueDate'],
      status: data['status'],
      xpGiven: widget.task?.xpGiven ?? false,
    );

    setState(() => _saving = true);
    final xp = await _controller.saveTask(task);
    if (!mounted) return;
    setState(() => _saving = false);

    String message = _isEdit ? s.tr('บันทึกการแก้ไขแล้ว', 'Changes saved') : s.tr('เพิ่มงานแล้ว', 'Task added');
    if (xp > 0) message = '$message 🎉 +$xp XP';
    showMessage(context, message);

    // ส่งค่า true กลับไปหน้าก่อนหน้า (return data from page บทที่ 5)
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final task = widget.task;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? s.tr('แก้ไขงาน', 'Edit Task') : s.tr('เพิ่มงานใหม่', 'New Task'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label(s.tr('ชื่อกิจกรรม', 'Title')),
                FormBuilderTextField(
                  name: 'title',
                  initialValue: task?.title,
                  decoration: InputDecoration(hintText: s.tr('เช่น อ่านหนังสือ 30 นาที', 'e.g. Read for 30 minutes')),
                  validator: FormBuilderValidators.required(errorText: s.tr('กรุณากรอกชื่อกิจกรรม', 'Please enter a title')),
                ),

                _label(s.tr('รายละเอียด', 'Details')),
                FormBuilderTextField(
                  name: 'description',
                  initialValue: task?.description,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: s.tr('ไม่บังคับ', 'Optional')),
                ),

                _label(s.tr('หมวดหมู่', 'Category')),
                FormBuilderDropdown<String>(
                  name: 'category',
                  initialValue: task?.category ?? 'personal',
                  items: TaskModel.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(TaskModel.categoryText(c, s.isThai))))
                      .toList(),
                ),

                _label(s.tr('วันครบกำหนด', 'Due date')),
                FormBuilderDateTimePicker(
                  name: 'dueDate',
                  initialValue: task?.dueDate ?? _defaultDate(),
                  inputType: InputType.both,
                  format: DateFormat('d MMM yyyy  HH:mm', s.isThai ? 'th' : 'en'),
                  decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_month)),
                  validator: FormBuilderValidators.required(errorText: s.tr('กรุณาเลือกวัน', 'Please pick a date')),
                ),

                _label(s.tr('สถานะ', 'Status')),
                FormBuilderDropdown<String>(
                  name: 'status',
                  initialValue: task?.status ?? 'todo',
                  items: TaskModel.statuses
                      .map((st) => DropdownMenuItem(value: st, child: Text(TaskModel.statusText(st, s.isThai))))
                      .toList(),
                ),

                _label(s.tr('ความสำคัญ', 'Importance')),
                FormBuilderRadioGroup<int>(
                  name: 'importance',
                  initialValue: task?.importance ?? 2,
                  orientation: OptionsOrientation.horizontal,
                  decoration: const InputDecoration(),
                  options: [1, 2, 3]
                      .map((i) => FormBuilderFieldOption(
                            value: i,
                            child: Text(TaskModel.importanceText(i, s.isThai)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  s.tr('⭐ ทำเสร็จได้ XP = ความสำคัญ × 10 (+5 ถ้าเสร็จก่อนกำหนด)',
                      '⭐ XP = importance × 10 (+5 if finished early)'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(s.tr('บันทึก', 'Save')),
                ),
                const SizedBox(height: 8),
                // ปุ่มล้างค่าในฟอร์ม
                TextButton(
                  onPressed: () => _formKey.currentState!.reset(),
                  child: Text(s.tr('ล้างค่า', 'Reset')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/ui_helpers.dart';
import 'task_form_page.dart';

// หน้าจอ 7: ปฏิทิน — เลือกวัน/เดือน/ปี แล้วแสดงงานของวันที่เลือก
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final TaskController _controller = TaskController();
  late Stream<List<TaskModel>> _taskStream;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _taskStream = _controller.getTasksStream();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.tr('ปฏิทิน', 'Calendar')),
        actions: [
          TextButton(
            onPressed: () => setState(() => _selectedDay = DateTime.now()),
            child: Text(s.tr('วันนี้', 'Today')),
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskStream,
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];
          final dayTasks = _controller.tasksOnDay(tasks, _selectedDay);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                // ปฏิทินของ Flutter (แตะหัวปฏิทินเพื่อเลือกเดือน/ปี)
                child: CalendarDatePicker(
                  key: ValueKey(_selectedDay),
                  initialDate: _selectedDay,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  onDateChanged: (day) => setState(() => _selectedDay = day),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatDate(_selectedDay, s.isThai)} (${dayTasks.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(s.tr('เพิ่ม', 'Add')),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaskFormPage(initialDate: _selectedDay)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (dayTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(s.tr('ไม่มีงานในวันนี้', 'No tasks on this day'),
                        style: const TextStyle(color: kGrey)),
                  ),
                )
              else
                Column(children: dayTasks.map((t) => TaskCard(task: t, showDate: false)).toList()),
            ],
          );
        },
      ),
    );
  }
}

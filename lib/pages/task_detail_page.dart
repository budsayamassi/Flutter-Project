import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_helpers.dart';
import 'task_form_page.dart';

// หน้ารายละเอียดงาน (รับข้อมูล task มาจากหน้าก่อนหน้า)
class TaskDetailPage extends StatelessWidget {
  final TaskModel task;
  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final controller = TaskController();
    final level = controller.priorityLevel(task);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.tr('รายละเอียดงาน', 'Task Detail')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: kPrimary),
            onPressed: () async {
              final saved = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
              );
              // ถ้าแก้ไขแล้วบันทึก ให้ปิดหน้านี้ด้วย (ข้อมูลเดิมเก่าแล้ว)
              if (saved == true && context.mounted) Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: kRed),
            onPressed: () async {
              final yes = await showConfirmDialog(
                context,
                title: s.tr('ลบงานนี้?', 'Delete this task?'),
                message: task.title,
                yesText: s.tr('ใช่', 'Yes'),
                noText: s.tr('ไม่', 'No'),
              );
              if (!yes) return;
              await controller.deleteTask(task);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(task.description, style: const TextStyle(fontSize: 15, color: kGrey)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _infoRow(Icons.folder, categoryColor(task.category), s.tr('หมวดหมู่', 'Category'),
                    TaskModel.categoryText(task.category, s.isThai)),
                _infoRow(Icons.calendar_month, task.isOverdue ? kRed : kPrimary, s.tr('วันครบกำหนด', 'Due date'),
                    formatDateTime(task.dueDate, s.isThai)),
                _infoRow(Icons.timelapse, kOrange, s.tr('สถานะ', 'Status'),
                    TaskModel.statusText(task.status, s.isThai)),
                _infoRow(Icons.star, kPurple, s.tr('ความสำคัญ', 'Importance'),
                    TaskModel.importanceText(task.importance, s.isThai)),
                _infoRow(Icons.flag, priorityColor(level), 'Priority Score', '${controller.score(task)} / 11'),
                _infoRow(Icons.emoji_events, kGreen, s.tr('รางวัล', 'Reward'),
                    task.xpGiven ? s.tr('ได้รับ XP แล้ว ✓', 'XP received ✓') : '${controller.xpFor(task)} XP'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: task.isDone ? kGrey : kGreen),
            icon: Icon(task.isDone ? Icons.undo : Icons.check),
            label: Text(task.isDone ? s.tr('ยังไม่เสร็จ', 'Mark as not done') : s.tr('ทำเสร็จแล้ว', 'Mark as done')),
            onPressed: () async {
              final xp = await controller.toggleDone(task);
              if (!context.mounted) return;
              if (xp > 0) showMessage(context, '🎉 ${s.tr('เยี่ยมมาก!', 'Great job!')} +$xp XP');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(color: kGrey, fontSize: 14)),
    );
  }
}

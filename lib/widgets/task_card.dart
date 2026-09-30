import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../pages/task_detail_page.dart';
import '../pages/task_form_page.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'ui_helpers.dart';

// การ์ดงาน 1 รายการ
// - ปัดไปทางขวา = แก้ไข, ปัดไปทางซ้าย = ลบ (Slidable บทที่ 4)
// - แตะวงกลม = ติ๊กเสร็จ, แตะการ์ด = ดูรายละเอียด
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool showDate;

  const TaskCard({super.key, required this.task, this.showDate = true});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final controller = TaskController();
    final level = controller.priorityLevel(task);
    final color = categoryColor(task.category);

    String timeText = showDate ? formatDateTime(task.dueDate, s.isThai) : formatTime(task.dueDate);
    if (task.isOverdue) {
      timeText = '$timeText · ${s.tr('เลยกำหนด', 'Overdue')}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          key: ValueKey(task.id),
          // ปัดจากซ้ายไปขวา → แก้ไข
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _openEdit(context),
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                icon: Icons.edit_rounded,
                label: s.tr('แก้ไข', 'Edit'),
              ),
            ],
          ),
          // ปัดจากขวาไปซ้าย → ลบ
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _confirmDelete(context, s),
                backgroundColor: kRed,
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
                label: s.tr('ลบ', 'Delete'),
              ),
            ],
          ),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                child: Row(
                  children: [
                    // แถบสีประจำหมวดหมู่
                    Container(
                      width: 4,
                      height: 44,
                      decoration: BoxDecoration(
                        color: task.isDone ? kGrey.withValues(alpha: 0.3) : color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ปุ่มติ๊กเสร็จ
                    GestureDetector(
                      onTap: () => _toggleDone(context, s),
                      child: Icon(
                        task.isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: task.isDone ? kGreen : kGrey.withValues(alpha: 0.6),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ชื่องาน + เวลา + หมวดหมู่
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: task.isDone ? kGrey : null,
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: task.isOverdue ? kRed : kGrey),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  timeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: task.isOverdue ? kRed : kGrey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  TaskModel.categoryText(task.category, s.isThai),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ธงบอกความเร่งด่วน
                    if (!task.isDone)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: priorityColor(level).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flag_rounded, size: 16, color: priorityColor(level)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
    );
  }

  Future<void> _toggleDone(BuildContext context, SettingsProvider s) async {
    final wasDone = task.isDone;
    await TaskController().toggleDone(task);
    if (!context.mounted) return;
    if (!wasDone) {
      showMessage(context, s.tr('ทำเสร็จแล้ว เยี่ยมมาก!', 'Done, great job!'));
    }
  }

  Future<void> _confirmDelete(BuildContext context, SettingsProvider s) async {
    final yes = await showConfirmDialog(
      context,
      title: s.tr('ลบงานนี้?', 'Delete this task?'),
      message: task.title,
      yesText: s.tr('ใช่', 'Yes'),
      noText: s.tr('ไม่', 'No'),
    );
    if (!yes) return;
    await TaskController().deleteTask(task);
    if (!context.mounted) return;
    showMessage(context, s.tr('ลบงานแล้ว', 'Task deleted'));
  }
}

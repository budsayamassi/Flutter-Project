import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../models/user_profile.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'task_form_page.dart';

// หน้าจอ 3: หน้าหลัก (Dashboard)
class HomePage extends StatefulWidget {
  final void Function(int index) onChangeTab; // ใช้สลับแท็บด้านล่าง
  const HomePage({super.key, required this.onChangeTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskController _controller = TaskController();
  late Stream<List<TaskModel>> _taskStream;
  late Stream<UserProfile?> _profileStream;

  @override
  void initState() {
    super.initState();
    // สร้าง Stream ครั้งเดียวตอนเริ่มหน้า (ไม่สร้างใหม่ทุกครั้งที่ build)
    _taskStream = _controller.getTasksStream();
    _profileStream = _controller.getProfileStream();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<UserProfile?>(
          stream: _profileStream,
          builder: (context, profileSnap) {
            final profile = profileSnap.data;

            return StreamBuilder<List<TaskModel>>(
              stream: _taskStream,
              builder: (context, taskSnap) {
                final tasks = taskSnap.data ?? [];
                final todayTasks = _controller.tasksOnDay(tasks, DateTime.now());
                final todayDone = todayTasks.where((t) => t.isDone).length;
                final topTasks = _controller.topPriorities(tasks);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    _buildHeader(s, profile),
                    const SizedBox(height: 20),
                    _buildProgressCard(s, todayDone, todayTasks.length),
                    const SizedBox(height: 16),
                    _buildStatsRow(s, tasks),
                    const SizedBox(height: 16),
                    _buildButtons(s),
                    const SizedBox(height: 28),
                    Text(
                      s.tr('ควรทำก่อน', 'Do first'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.tr('เรียงตาม Priority Score จากมากไปน้อย', 'Sorted by Priority Score'),
                      style: const TextStyle(fontSize: 13, color: kGrey),
                    ),
                    const SizedBox(height: 12),
                    if (taskSnap.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (topTasks.isEmpty)
                      _buildEmpty(s)
                    else
                      Column(children: topTasks.map((t) => TaskCard(task: t)).toList()),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------- ทักทาย + รูปโปรไฟล์ ----------
  Widget _buildHeader(SettingsProvider s, UserProfile? profile) {
    final name = profile?.name ?? 'User';
    final today = DateFormat('EEEE d MMMM', s.isThai ? 'th' : 'en').format(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(today, style: const TextStyle(color: kGrey, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                '${s.tr('สวัสดี', 'Hi')}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => widget.onChangeTab(3), // ไปแท็บโปรไฟล์
          child: CircleAvatar(
            radius: 24,
            backgroundColor: kPrimary,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- ความคืบหน้าวันนี้ (การ์ดสีฟ้า Gradient) ----------
  Widget _buildProgressCard(SettingsProvider s, int done, int total) {
    final double percent = total == 0 ? 0 : done / total;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: kPrimary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                Text(
                  '$done/$total',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr('ความคืบหน้าวันนี้', "Today's progress"),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  total == 0
                      ? s.tr('วันนี้ยังไม่มีงาน', 'No tasks today')
                      : s.tr('ของงานวันนี้เสร็จแล้ว', "of today's tasks done"),
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- สรุปจำนวนงาน: ทั้งหมด / เสร็จแล้ว / เลยกำหนด ----------
  Widget _buildStatsRow(SettingsProvider s, List<TaskModel> tasks) {
    final doneCount = tasks.where((t) => t.isDone).length;
    final overdueCount = tasks.where((t) => t.isOverdue).length;

    return Row(
      children: [
        _statBox(Icons.assignment_rounded, '${tasks.length}', s.tr('งานทั้งหมด', 'All tasks'), kPrimary),
        const SizedBox(width: 10),
        _statBox(Icons.check_circle_rounded, '$doneCount', s.tr('เสร็จแล้ว', 'Done'), kGreen),
        const SizedBox(width: 10),
        _statBox(Icons.schedule_rounded, '$overdueCount', s.tr('เลยกำหนด', 'Overdue'), kRed),
      ],
    );
  }

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: kGrey)),
          ],
        ),
      ),
    );
  }

  // ---------- ปุ่มเพิ่มงาน / ปฏิทิน ----------
  Widget _buildButtons(SettingsProvider s) {
    return Row(
      children: [
        Expanded(
          child: _menuButton(
            icon: Icons.add_rounded,
            label: s.tr('เพิ่มงาน', 'Add task'),
            color: kPrimary,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskFormPage()));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _menuButton(
            icon: Icons.calendar_month_rounded,
            label: s.tr('ปฏิทิน', 'Calendar'),
            color: kTeal,
            onTap: () => widget.onChangeTab(2),
          ),
        ),
      ],
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(SettingsProvider s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.task_alt_rounded, size: 44, color: kGreen),
            const SizedBox(height: 8),
            Text(s.tr('เคลียร์งานหมดแล้ว!', 'All clear!'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(s.tr('เพิ่มงานใหม่ หรือพักผ่อนสักหน่อย', 'Add a new task or take a break'),
                style: const TextStyle(color: kGrey)),
          ],
        ),
      ),
    );
  }
}

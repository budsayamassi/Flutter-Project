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
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(s, profile),
                    const SizedBox(height: 20),
                    _buildProgressCard(s, todayDone, todayTasks.length),
                    const SizedBox(height: 12),
                    if (profile != null) _buildLevelCard(s, profile),
                    const SizedBox(height: 12),
                    _buildButtons(s),
                    const SizedBox(height: 24),
                    Text(
                      s.tr('ควรทำก่อน', 'Do first'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (taskSnap.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (topTasks.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.celebration, size: 48, color: kGreen),
                              const SizedBox(height: 8),
                              Text(s.tr('เคลียร์งานหมดแล้ว!', 'All clear!'),
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      )
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
              Text(today, style: const TextStyle(color: kGrey)),
              Text(
                '${s.tr('สวัสดี', 'Hi')}, $name 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => widget.onChangeTab(3), // ไปแท็บโปรไฟล์
          child: CircleAvatar(
            radius: 24,
            backgroundColor: kPrimary.withValues(alpha: 0.15),
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- ความคืบหน้าวันนี้ ----------
  Widget _buildProgressCard(SettingsProvider s, int done, int total) {
    final double percent = total == 0 ? 0 : done / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 8,
                      backgroundColor: kGrey.withValues(alpha: 0.2),
                    ),
                  ),
                  Text('$done/$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.tr('ความคืบหน้าวันนี้', "Today's progress"), style: const TextStyle(color: kGrey)),
                  Text('${(percent * 100).round()}%',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Text(
                    total == 0
                        ? s.tr('วันนี้ยังไม่มีงาน', 'No tasks today')
                        : s.tr('ของงานวันนี้เสร็จแล้ว', "of today's tasks done"),
                    style: const TextStyle(fontSize: 13, color: kGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Level / XP / Streak ----------
  Widget _buildLevelCard(SettingsProvider s, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(profile.plantEmoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Level ${profile.level}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('🔥 ${profile.streak} ${s.tr('วัน', 'days')}',
                          style: const TextStyle(color: kOrange, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: profile.xpInLevel / 100,
                      minHeight: 8,
                      color: kGreen,
                      backgroundColor: kGrey.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${profile.xpInLevel} / 100 XP', style: const TextStyle(fontSize: 12, color: kGrey)),
                ],
              ),
            ),
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
            icon: Icons.add_circle_outline,
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
            icon: Icons.calendar_month,
            label: s.tr('ปฏิทิน', 'Calendar'),
            color: kRed,
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

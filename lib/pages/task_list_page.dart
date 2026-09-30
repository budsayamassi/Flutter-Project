import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'task_form_page.dart';

// หน้าจอ 4: งานทั้งหมด (ค้นหา + แบ่งแท็บตามสถานะด้วย TabBar)
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskController _controller = TaskController();
  late Stream<List<TaskModel>> _taskStream;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _taskStream = _controller.getTasksStream();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    // แต่ละแท็บ = สถานะที่ใช้กรอง
    const tabStatuses = ['all', 'todo', 'doing', 'done'];

    return DefaultTabController(
      length: tabStatuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.tr('งานทั้งหมด', 'All Tasks')),
          bottom: TabBar(
            labelColor: kPrimary,
            unselectedLabelColor: kGrey,
            indicatorColor: kPrimary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: s.tr('ทั้งหมด', 'All')),
              const Tab(text: 'To Do'),
              Tab(text: s.tr('กำลังทำ', 'Doing')),
              Tab(text: s.tr('เสร็จแล้ว', 'Done')),
            ],
          ),
        ),
        body: Column(
          children: [
            // แถบค้นหา
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: s.tr('ค้นหา', 'Search'),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<TaskModel>>(
                stream: _taskStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tasks = snapshot.data ?? [];

                  return TabBarView(
                    children: tabStatuses.map((status) {
                      final list = _controller.filterTasks(tasks, status, _search);
                      if (list.isEmpty) {
                        return Center(
                          child: Text(s.tr('ไม่มีงาน', 'No tasks'), style: const TextStyle(color: kGrey)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: list.length,
                        itemBuilder: (context, index) => TaskCard(task: list[index]),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                s.tr('ปัดขวาเพื่อแก้ไข · ปัดซ้ายเพื่อลบ', 'Swipe right to edit · left to delete'),
                style: const TextStyle(fontSize: 12, color: kGrey),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskFormPage()));
          },
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'calendar_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'task_list_page.dart';

// โครงหลักหลัง Login: แถบเมนูด้านล่าง 4 แท็บ (บทที่ 5)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    final pages = [
      HomePage(onChangeTab: _changeTab),
      const TaskListPage(),
      const CalendarPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changeTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: s.tr('หน้าหลัก', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_rounded),
            selectedIcon: const Icon(Icons.checklist_rtl_rounded),
            label: s.tr('งาน', 'Tasks'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: s.tr('ปฏิทิน', 'Calendar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: s.tr('โปรไฟล์', 'Profile'),
          ),
        ],
      ),
    );
  }
}

import '../models/task_model.dart';
import '../models/user_profile.dart';
import '../services/priority_service.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';

// สะพานเชื่อมระหว่างหน้าจอกับ Service ที่เกี่ยวกับงาน
class TaskController {
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  final PriorityService _priorityService = PriorityService();

  Stream<List<TaskModel>> getTasksStream() => _taskService.getTasksStream();
  Stream<UserProfile?> getProfileStream() => _userService.getProfileStream();

  int score(TaskModel task) => _priorityService.score(task);
  int priorityLevel(TaskModel task) => _priorityService.level(task);
  int xpFor(TaskModel task) => _priorityService.xpFor(task);

  // บันทึกงาน (ถ้ายังไม่มี id = เพิ่มใหม่, มี id แล้ว = แก้ไข)
  // คืนค่า XP ที่ได้ (ถ้าบันทึกเป็นสถานะ "เสร็จแล้ว")
  Future<int> saveTask(TaskModel task) async {
    int xpGained = 0;
    if (task.isDone && !task.xpGiven) {
      xpGained = await _giveXp(task);
      task.xpGiven = true;
    }

    if (task.id.isEmpty) {
      await _taskService.addTask(task);
    } else {
      await _taskService.updateTask(task);
    }
    return xpGained;
  }

  // ติ๊กเสร็จ / ยกเลิกเสร็จ — คืนค่า XP ที่ได้
  Future<int> toggleDone(TaskModel task) async {
    if (task.isDone) {
      task.status = 'todo';
    } else {
      task.status = 'done';
    }
    return saveTask(task);
  }

  Future<void> deleteTask(TaskModel task) async {
    await _taskService.deleteTask(task.id);
  }

  // เพิ่ม XP, นับ Streak และจำนวนงานที่เสร็จ ให้ผู้ใช้
  Future<int> _giveXp(TaskModel task) async {
    final profile = await _userService.getProfile();
    if (profile == null) return 0;

    final xp = _priorityService.xpFor(task);
    profile.xp = profile.xp + xp;
    profile.totalDone = profile.totalDone + 1;
    profile.streak = _priorityService.newStreak(profile.lastActiveDate, profile.streak);
    profile.lastActiveDate = _priorityService.dayKey(DateTime.now());

    await _userService.updateStats(profile);
    return xp;
  }

  // ---------- ตัวกรองรายการงาน ----------
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TaskModel> tasksOnDay(List<TaskModel> tasks, DateTime day) {
    return tasks.where((t) => isSameDay(t.dueDate, day)).toList();
  }

  // 3 งานที่ควรทำก่อน (ยังไม่เสร็จ และ Priority Score สูงสุด)
  List<TaskModel> topPriorities(List<TaskModel> tasks) {
    final notDone = tasks.where((t) => !t.isDone).toList();
    notDone.sort((a, b) => score(b).compareTo(score(a)));
    return notDone.take(3).toList();
  }

  List<TaskModel> filterTasks(List<TaskModel> tasks, String status, String search) {
    final keyword = search.trim().toLowerCase();
    return tasks.where((t) {
      final matchStatus = status == 'all' || t.status == status;
      final matchSearch = keyword.isEmpty || t.title.toLowerCase().contains(keyword);
      return matchStatus && matchSearch;
    }).toList();
  }
}

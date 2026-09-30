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

  // บันทึกงาน (ถ้ายังไม่มี id = เพิ่มใหม่, มี id แล้ว = แก้ไข)
  Future<void> saveTask(TaskModel task) async {
    if (task.id.isEmpty) {
      await _taskService.addTask(task);
    } else {
      await _taskService.updateTask(task);
    }
  }

  // ติ๊กเสร็จ / ยกเลิกเสร็จ
  Future<void> toggleDone(TaskModel task) async {
    if (task.isDone) {
      task.status = 'todo';
    } else {
      task.status = 'done';
    }
    await saveTask(task);
  }

  Future<void> deleteTask(TaskModel task) async {
    await _taskService.deleteTask(task.id);
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

import '../models/task_model.dart';

// Business Logic สำหรับคำนวณ Priority Score
// (ไม่ยุ่งกับหน้าจอ เหมือน BmrService ในห้องเรียน)
class PriorityService {
  // ความเร่งด่วน: เลยกำหนด=5, วันนี้=4, พรุ่งนี้=3, ภายใน 3 วัน=2, ภายใน 7 วัน=1, นานกว่านั้น=0
  int urgency(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return 5;

    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final daysLeft = dueDay.difference(today).inDays;

    if (daysLeft == 0) return 4;
    if (daysLeft == 1) return 3;
    if (daysLeft <= 3) return 2;
    if (daysLeft <= 7) return 1;
    return 0;
  }

  // Priority Score = (ความสำคัญ x 2) + ความเร่งด่วน  (เต็ม 11)
  int score(TaskModel task) {
    return task.importance * 2 + urgency(task.dueDate);
  }

  // ระดับสี: 3 = แดง (ด่วนมาก), 2 = ส้ม, 1 = เขียว
  int level(TaskModel task) {
    final s = score(task);
    if (s >= 9) return 3;
    if (s >= 6) return 2;
    return 1;
  }
}

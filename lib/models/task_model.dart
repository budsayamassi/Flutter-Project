import 'package:cloud_firestore/cloud_firestore.dart';

// โครงสร้างข้อมูลของงาน 1 รายการ
// เก็บใน Firestore ที่ users/{uid}/tasks/{id}
class TaskModel {
  String id;
  String title;
  String description;
  String category; // work, study, personal, health, other
  int importance; // 1 = ต่ำ, 2 = กลาง, 3 = สูง
  DateTime dueDate;
  String status; // todo, doing, done

  TaskModel({
    this.id = '',
    required this.title,
    this.description = '',
    this.category = 'personal',
    this.importance = 2,
    required this.dueDate,
    this.status = 'todo',
  });

  bool get isDone => status == 'done';

  // เลยกำหนดแล้วแต่ยังไม่เสร็จ
  bool get isOverdue => !isDone && dueDate.isBefore(DateTime.now());

  // แปลงเป็น Map เพื่อบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'importance': importance,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
    };
  }

  // แปลงข้อมูลจาก Firestore กลับเป็น TaskModel
  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'other',
      importance: data['importance'] ?? 2,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'todo',
    );
  }

  // ---------- ข้อความสำหรับแสดงผล ----------
  static const List<String> categories = ['work', 'study', 'personal', 'health', 'other'];
  static const List<String> statuses = ['todo', 'doing', 'done'];

  static String categoryText(String category, bool isThai) {
    if (category == 'work') return isThai ? 'งาน' : 'Work';
    if (category == 'study') return isThai ? 'เรียนรู้' : 'Study';
    if (category == 'personal') return isThai ? 'ส่วนตัว' : 'Personal';
    if (category == 'health') return isThai ? 'สุขภาพ' : 'Health';
    return isThai ? 'อื่นๆ' : 'Other';
  }

  static String statusText(String status, bool isThai) {
    if (status == 'doing') return isThai ? 'กำลังทำ' : 'Doing';
    if (status == 'done') return isThai ? 'เสร็จแล้ว' : 'Done';
    return 'To Do';
  }

  static String importanceText(int importance, bool isThai) {
    if (importance == 3) return isThai ? 'สูง' : 'High';
    if (importance == 2) return isThai ? 'กลาง' : 'Medium';
    return isThai ? 'ต่ำ' : 'Low';
  }
}

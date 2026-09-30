import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

// เพิ่ม / อ่าน / แก้ไข / ลบ งานใน Cloud Firestore (บทที่ 10)
class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // งานของผู้ใช้แต่ละคนแยกเก็บที่ users/{uid}/tasks
  CollectionReference<Map<String, dynamic>> _taskCollection() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // อ่านงานทั้งหมดแบบ Realtime เรียงตามวันครบกำหนด
  Stream<List<TaskModel>> getTasksStream() {
    return _taskCollection().orderBy('dueDate').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _taskCollection().add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskCollection().doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection().doc(id).delete();
  }
}

# Questly — To-do ที่เปลี่ยนงานประจำวันให้เป็นเควส

แอปจัดการงาน (Flutter + Firebase) ดีไซน์คลีนโทนขาว–ฟ้า เปลี่ยนภาษาไทย/อังกฤษ และธีมมืด/สว่างได้

## จุดเด่น
- **Priority Score:** คำนวณความสำคัญของงานอัตโนมัติ = (ความสำคัญ × 2) + ความเร่งด่วน แล้วแสดง 3 งานที่ "ควรทำก่อน"
- **XP / Level / Streak:** ทำงานเสร็จได้ XP (ความสำคัญ × 10, +5 ถ้าเสร็จก่อนกำหนด) ทุก 100 XP ขึ้น 1 Level และต้นไม้ประจำตัวจะโตขึ้น 🌱→🌿→🪴→🌳

## หน้าจอ
| # | หน้าจอ | ไฟล์ |
|---|---|---|
| – | Splash (มี Animation) | `pages/splash_page.dart` |
| 1 | เข้าสู่ระบบ | `pages/login_page.dart` |
| 2 | สมัครสมาชิก | `pages/register_page.dart` |
| – | ลืมรหัสผ่าน | `pages/forgot_password_page.dart` |
| 3 | หน้าหลัก (Dashboard) | `pages/home_page.dart` |
| 4 | งานทั้งหมด (ค้นหา + TabBar + ปัดแก้ไข/ลบ) | `pages/task_list_page.dart` |
| 5 | เพิ่ม/แก้ไขงาน | `pages/task_form_page.dart` |
| – | รายละเอียดงาน | `pages/task_detail_page.dart` |
| 6 | Profile | `pages/profile_page.dart` |
| – | แก้ไขข้อมูล / เปลี่ยนรหัสผ่าน | `pages/edit_profile_page.dart`, `pages/change_password_page.dart` |
| 7 | ปฏิทิน | `pages/calendar_page.dart` |

## โครงสร้างโปรเจกต์ (ตามบทที่ 7)
```
lib/
├ main.dart              # เริ่มแอป: Firebase, Provider, ธีม, ภาษา
├ models/                # โครงสร้างข้อมูล: TaskModel, UserProfile
├ pages/                 # หน้าจอต่างๆ
├ controllers/           # สะพานเชื่อมหน้าจอกับ Service
├ services/              # ติดต่อ Firebase + คำนวณ Priority/XP/Streak
├ providers/             # SettingsProvider (ธีม/ภาษา)
├ widgets/               # ชิ้นส่วน UI ที่ใช้ซ้ำ: TaskCard, AppLogo, ui_helpers
└ theme/                 # สีและธีมของแอป
```
การทำงาน: **Page → Controller → Service → Firebase**

## เนื้อหาในห้องเรียนที่ใช้
| บท | ใช้ในแอป |
|---|---|
| 2 Dart | class, List, Map, if/else, async/await |
| 3 Layout | Row, Column, Stack, Card, ListView |
| 4 UI | Slidable (ปัดแก้ไข/ลบ), AlertDialog, flutter_animate (Splash) |
| 5 Navigation | BottomNavigationBar, TabBar, push/pop, ส่งข้อมูลไปหน้าใหม่, ส่งค่ากลับ, pushReplacement, pushAndRemoveUntil |
| 6 Form | flutter_form_builder + form_builder_validators |
| 7 Structure & State | models/pages/controllers/services/providers, Provider + ChangeNotifier, initState |
| 9 Shared Storage | SharedPreferences เก็บธีมและภาษา |
| 10 Cloud Firestore | เก็บงาน/โปรไฟล์, StreamBuilder แบบ Realtime |
| 11 Firebase Auth | Login, สมัคร, ลืมรหัสผ่าน, เปลี่ยนรหัสผ่าน, Logout |

## ฐานข้อมูล (Cloud Firestore)
```
users/{uid}                 name, email, xp, streak, lastActiveDate, totalDone
users/{uid}/tasks/{id}      title, description, category, importance, dueDate, status, xpGiven
```

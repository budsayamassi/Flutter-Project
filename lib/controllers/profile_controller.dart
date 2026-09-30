import '../models/user_profile.dart';
import '../services/user_service.dart';

// สะพานเชื่อมระหว่างหน้าโปรไฟล์กับ UserService
class ProfileController {
  final UserService _userService = UserService();

  Stream<UserProfile?> getProfileStream() => _userService.getProfileStream();

  Future<void> updateName(String name) async {
    await _userService.updateName(name.trim());
  }
}

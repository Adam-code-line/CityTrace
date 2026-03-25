import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/user_controller.dart';
import '../../services/journey_management/journey_service.dart';
import '../../models/user_model.dart';
import '../../core/utils/storage_util.dart';
import '../../services/auth_service.dart';

class ProfileController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final JourneyService _journeyService = JourneyService();
  final AuthService _authService = AuthService();

  // 对外提供用户信息
  UserModel? get currentUser => _userController.user;

  // 响应式数据
  final RxInt totalMileage = 0.obs; // 总里程（米）
  final RxInt totalPoints = 0.obs; // 足迹点个数
  final RxString totalDuration = "00:00:00".obs; // 总探索时长
  final RxBool isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  /// 加载用户个人资料和统计数据
  Future<void> _loadUserProfile() async {
    if (!_userController.isLoggedIn) {
      return;
    }

    isLoadingStats.value = true;

    try {
      // 获取行程列表以计算统计数据
      final journeys = await _journeyService.getJourneyList(page: 1, size: 100);

      int mileage = 0;
      int points = 0;

      for (var journey in journeys) {
        // 这里需要根据实际的行程数据计算里程和点数
        // 暂时设置为示例值
        points += 10; // 假设每个行程有10个点
      }

      totalPoints.value = points;
      totalMileage.value = mileage;
      totalDuration.value = _formatDuration(points * 60); // 假设每个点1分钟
    } catch (e) {
      print("加载用户资料失败: $e");
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// 格式化时长
  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}";
  }

  /// 退出登录
  void logout() => _userController.logout();

  /// 更新用户名
  Future<void> updateUsername(String newUsername) async {
    if (currentUser == null) return;

    try {
      // 这里应该调用后端API更新用户名
      // 暂时模拟更新过程
      await Future.delayed(const Duration(milliseconds: 500));

      // 更新本地用户信息
      final updatedUser = UserModel(
        userId: currentUser!.userId,
        account: currentUser!.account,
        username: newUsername,
        avatar: currentUser!.avatar,
      );

      // 更新全局用户状态（不触发导航）
      _userController.updateUserInfo(updatedUser);

      // 更新本地存储
      StorageUtil.setUsername(newUsername);
    } catch (e) {
      print("更新用户名失败: $e");
      rethrow;
    }
  }

  /// 选择并更新头像
  Future<void> updateAvatar() async {
    if (currentUser == null) return;

    try {
      // 显示选择方式对话框
      final ImagePicker picker = ImagePicker();

      // 选择图片来源
      final XFile? image = await Get.dialog<XFile?>(
        Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "选择头像来源",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? photo = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 80,
                    );
                    Get.back(result: photo);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("拍照"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 80,
                    );
                    Get.back(result: image);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text("从相册选择"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("取消"),
                ),
              ],
            ),
          ),
        ),
      );

      if (image != null) {
        // 上传头像到服务器
        final File imageFile = File(image.path);
        final String? avatarUrl = await _authService.uploadAvatar(imageFile);

        if (avatarUrl != null) {
          // 更新本地用户信息
          final updatedUser = UserModel(
            userId: currentUser!.userId,
            account: currentUser!.account,
            username: currentUser!.username,
            avatar: avatarUrl,
          );

          // 更新全局用户状态（不触发导航）
          _userController.updateUserInfo(updatedUser);

          // 更新本地存储
          StorageUtil.setAvatar(avatarUrl);

          Get.snackbar("成功", "头像更新成功");
        } else {
          Get.snackbar("错误", "头像上传失败，请重试");
        }
      }
    } catch (e) {
      print("更新头像失败: $e");
      Get.snackbar("错误", "头像更新失败，请重试");
    }
  }
}

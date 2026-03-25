import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/utils/storage_util.dart';

class UserController extends GetxController {
  final AuthService _authService = AuthService();

  // 使用 .obs 使变量变为响应式
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool _isLoggedIn = false.obs;

  // 获取器
  UserModel? get user => _user.value;
  bool get isLoggedIn => _isLoggedIn.value;
  RxBool get isLoggedInRx => _isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    // App 启动时，尝试从本地加载缓存并检查登录状态
    _loadLocalProfile();
    checkLoginStatus();
  }

  /// 检查登录状态
  Future<void> checkLoginStatus() async {
    String? token = StorageUtil.getToken();
    if (token != null && token.isNotEmpty) {
      // 尝试获取最新的个人资料
      UserModel? profile = await _authService.getProfile();
      if (profile != null) {
        _user.value = profile;
        _isLoggedIn.value = true;
        StorageUtil.setUserId(profile.userId);
        StorageUtil.setUsername(profile.username);
        if (profile.avatar != null) StorageUtil.setAvatar(profile.avatar!);
      } else {
        // 如果获取资料失败（可能是 Token 过期），则清理
        logout();
      }
    }
  }

  void _loadLocalProfile() {
    String? name = StorageUtil.getUsername();
    String? avatar = StorageUtil.getAvatar();
    if (name != null) {
      // 构造一个简单的假对象用于展示
      _user.value = UserModel(
        userId: "",
        account: "",
        username: name,
        avatar: avatar,
      );
      _isLoggedIn.value = true;
    }
  }

  /// 处理登录成功后的状态更新
  void onLoginSuccess(UserModel user) {
    _user.value = user;
    _isLoggedIn.value = true;
    StorageUtil.setUserId(user.userId);
    StorageUtil.setUsername(user.username);
    if (user.avatar != null) StorageUtil.setAvatar(user.avatar!);
    // 登录成功后跳转到主页
    Get.offAllNamed('/home');
  }

  /// 更新用户信息（不触发导航）
  void updateUserInfo(UserModel user) {
    _user.value = user;
    StorageUtil.setUserId(user.userId);
    StorageUtil.setUsername(user.username);
    if (user.avatar != null) StorageUtil.setAvatar(user.avatar!);
  }

  /// 统一的注销/过期跳转逻辑
  void handleAuthLoss({bool toLogin = false}) {
    // 清理内存状态
    _user.value = null;
    _isLoggedIn.value = false;

    // 清理本地存储
    StorageUtil.clearAll();

    Get.offAllNamed('/');
    if (toLogin) Get.toNamed('/login');
  }

  /// 退出登录
  Future<void> logout() async {
    await _authService.logout();
    handleAuthLoss();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static late SharedPreferences _prefs;

  // 初始化方法
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token 相关
  static const String _keyToken = "token";

  static Future<bool> setToken(String value) =>
      _prefs.setString(_keyToken, value);
  static String? getToken() => _prefs.getString(_keyToken);
  static Future<bool> removeToken() => _prefs.remove(_keyToken);

  // 用户 ID 用户名 相关
  static const String _keyUserId = "userId";

  static Future<bool> setUserId(String value) =>
      _prefs.setString(_keyUserId, value);
  static String? getUserId() => _prefs.getString(_keyUserId);

  static const String _keyUsername = "username";

  static Future<bool> setUsername(String value) =>
      _prefs.setString(_keyUsername, value);
  static String? getUsername() => _prefs.getString(_keyUsername);

  static const String _keyAvatar = "avatar_url";

  static Future<bool> setAvatar(String value) =>
      _prefs.setString(_keyAvatar, value);
  static String? getAvatar() => _prefs.getString(_keyAvatar);

  // 行程 相关
  static const String _keyJourneyId = "journeyId";

  static Future<bool> setJourneyId(String value) =>
      _prefs.setString(_keyJourneyId, value);
  static String? getJourneyId() => _prefs.getString(_keyJourneyId);
  static Future<bool> removeJourneyId() => _prefs.remove(_keyJourneyId);

  // 目标路由相关
  static const String _keyTargetRoute = "targetRoute";

  static Future<bool> setTargetRoute(String value) =>
      _prefs.setString(_keyTargetRoute, value);
  static String? getTargetRoute() => _prefs.getString(_keyTargetRoute);
  static Future<bool> removeTargetRoute() => _prefs.remove(_keyTargetRoute);

  // 退出登录清理缓存
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}

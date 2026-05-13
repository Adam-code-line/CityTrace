/// Mock 配置
/// 当 [enableMock] 为 true 时，API 请求将被 MockInterceptor 拦截并返回模拟数据
class MockConfig {
  /// 是否启用 Mock 模式（开发调试用）
  /// true  = 不请求后端，使用本地模拟数据
  /// false = 正常请求后端 API
  static bool enableMock = true;

  /// 模拟登录延迟（毫秒），模拟网络请求耗时
  static int mockDelayMs = 800;

  /// 模拟普通请求延迟（毫秒）
  static int mockNormalDelayMs = 300;
}
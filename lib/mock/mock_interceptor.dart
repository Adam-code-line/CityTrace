import 'package:dio/dio.dart';
import 'mock_config.dart';
import 'mock_data.dart';

/// Mock 拦截器
/// 在 Dio 请求发送前拦截，直接返回模拟数据
/// 当 [MockConfig.enableMock] 为 true 时启用
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!MockConfig.enableMock) {
      return handler.next(options);
    }

    // Dio 的 options.path 是完整 URL（包含 baseUrl），需要提取 API 路径
    // 例如: "http://10.0.2.2:4523/m1/.../api/v1/user/login"
    // 需要提取: "/user/login"
    final apiPath = _extractApiPath(options.path);

    // 获取 body 数据（POST/PUT/PATCH 的请求体）
    Map<String, dynamic>? body;
    if (options.data is Map) {
      body = options.data as Map<String, dynamic>;
    }

    // 查询参数也在匹配范围内（用于 GET 请求的分页等参数）
    if (options.queryParameters.isNotEmpty) {
      body ??= {};
      body.addAll(options.queryParameters);
    }

    // 查找匹配的模拟响应
    final mockResponse = MockData.getResponse(
      options.method,
      apiPath,
      body,
    );

    if (mockResponse != null) {
      // 模拟网络延迟
      final delay = _isAuthPath(apiPath)
          ? MockConfig.mockDelayMs
          : MockConfig.mockNormalDelayMs;

      Future.delayed(Duration(milliseconds: delay), () {
        // 构建与真实 Dio 响应一致的 Response 对象
        final response = Response(
          requestOptions: options,
          data: mockResponse,
          statusCode: 200,
          statusMessage: 'OK',
        );
        handler.resolve(response);
      });
    } else {
      // 未匹配到 Mock 数据，记录警告并放行
      // 这样即使有未覆盖的接口也不会崩溃
      print('[Mock] ⚠️ 未匹配到模拟数据: ${options.method} $apiPath');
      print('[Mock]    完整路径: ${options.path}');
      handler.next(options);
    }
  }

  /// 从完整 URL 中提取 API 路径部分
  /// 输入: "http://10.0.2.2:4523/m1/7557631-7295075-default/api/v1/user/login"
  /// 输出: "/user/login"
  String _extractApiPath(String fullUrl) {
    // 查找 "/api/v1/" 后面的路径
    final apiPrefix = '/api/v1';
    final apiIndex = fullUrl.indexOf(apiPrefix);
    if (apiIndex != -1) {
      return fullUrl.substring(apiIndex + apiPrefix.length);
    }
    // 如果找不到 /api/v1，尝试找 URI 的路径部分
    try {
      final uri = Uri.parse(fullUrl);
      return uri.path;
    } catch (_) {
      // 如果解析失败，直接返回原始路径
      return fullUrl;
    }
  }

  /// 判断是否为认证相关路径（登录/注册等需要更长的模拟延迟）
  bool _isAuthPath(String path) {
    return path.contains('/user/login') || path.contains('/user/register');
  }
}

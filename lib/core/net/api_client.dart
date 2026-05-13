import 'package:citytrace/controllers/user_controller.dart';
import 'package:citytrace/mock/mock_config.dart';
import 'package:citytrace/mock/mock_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getx;
import '../../common/values/server.dart';
import '../utils/storage_util.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient.internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient.internal() {
    BaseOptions options = BaseOptions(
      baseUrl: ServerConfig.BASE_URL,
      connectTimeout: const Duration(
        milliseconds: ServerConfig.CONNECT_TIMEOUT,
      ),
      receiveTimeout: const Duration(
        milliseconds: ServerConfig.RECEIVE_TIMEOUT,
      ),
      headers: {},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // 如果启用 Mock 模式，优先添加 Mock 拦截器
    if (MockConfig.enableMock) {
      dio.interceptors.add(MockInterceptor());
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 登录状态下统一添加 JWT Token
          String? token = StorageUtil.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final data = response.data;

          if (data is! Map) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: "服务器返回数据格式异常",
                type: DioExceptionType.badResponse,
              ),
            );
          }

          final int code = data["code"] ?? -1;
          final String msg = data["msg"] ?? "未知错误";

          if (code == 0) {
            // 请求成功，返回响应
            return handler.next(response);
          } else {
            _dispatchError(code, msg);
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: msg,
                type: DioExceptionType.badResponse,
              ),
            );
          }
        },
        onError: (DioException e, handler) {
          // 尝试从异常响应中提取业务错误
          final response = e.response;

          if (response != null && response.data is Map) {
            final data = response.data;
            // 情况 A：后端返回了标准的业务错误 JSON
            if (data.containsKey("code") && data.containsKey("msg")) {
              _dispatchError(data["code"], data["msg"]);
            } else {
              // 情况 B：后端返回了非标准响应
              _handlePureHttpError(e);
            }
          } else {
            // 情况 C：其他情况
            _handlePureHttpError(e);
          }

          return handler.next(e);
        },
      ),
    );

    // debug用日志拦截器
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    );
  }

  // 统一业务错误处理
  void _dispatchError(int code, String msg) {
    // 全局弹窗
    Fluttertoast.showToast(
      msg: "[$code] $msg",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    // 特殊逻辑：如登录失效
    if (code == 2001 || code == 2002) {
      getx.Get.find<UserController>().handleAuthLoss(toLogin: true);
    }
  }

  // 网络层面错误
  void _handlePureHttpError(DioException e) {
    String message = "系统开小差了，请稍后再试";

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      message = "无法连接到服务器，请检查网络设置";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = "服务器响应超时";
    } else if (e.response?.statusCode == 404) {
      message = "接口路径不存在 (404)";
    } else if (e.response?.statusCode == 500) {
      message = "服务器内部错误 (500)";
    }

    Fluttertoast.showToast(msg: message);
  }

  // 对外暴露请求方法
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:task_manager/data/services/api_endpoints.dart';
import 'package:task_manager/data/services/shared_preference.dart';

class ApiClient {
  late final Dio dio;

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoint.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _addInterceptors();
    _restoreToken();
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  void _addInterceptors() {
    _setupPrettyLogging();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final sharedPrefs = Get.find<SharedPreference>();
        final token = sharedPrefs.getString(_tokenKey);

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              final sharedPrefs = Get.find<SharedPreference>();
              sharedPrefs.saveString(_tokenKey, newToken);

              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            Get.offAllNamed('/login');
          }
        }

        return handler.next(error);
      },
    ));
  }

  void _setupPrettyLogging() {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  void _restoreToken() {
    try {
      final sharedPrefs = Get.find<SharedPreference>();
      final token = sharedPrefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final sharedPrefs = Get.find<SharedPreference>();
      final refreshToken = sharedPrefs.getString(_refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await dio.post(
        ApiEndpoint.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.data['success'] == true) {
        return response.data['data']['accessToken'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    final sharedPrefs = Get.find<SharedPreference>();
    sharedPrefs.saveString(_tokenKey, token);
  }

  void removeAuthToken() {
    dio.options.headers.remove('Authorization');
    final sharedPrefs = Get.find<SharedPreference>();
    sharedPrefs.removeKey(_tokenKey);
    sharedPrefs.removeKey(_refreshTokenKey);
  }
}
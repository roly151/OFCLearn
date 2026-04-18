import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    Map<String, Object> defaultHeaders = const <String, Object>{},
  })  : _tokenStorage = tokenStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
            headers: <String, Object>{
              'Accept': 'application/json',
              ...defaultHeaders,
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> getMap(String path) async {
    final response = await _guard(() => _dio.get<dynamic>(path));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiException(message: 'Expected an object response.');
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _guard(() => _dio.get<dynamic>(path));
    final data = response.data;
    if (data is List<dynamic>) {
      return data;
    }
    throw const ApiException(message: 'Expected a list response.');
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
  }) async {
    final response = await _guard(
      () => _dio.post<dynamic>(path, data: data),
    );
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return body;
    }
    throw const ApiException(message: 'Expected an object response.');
  }

  Future<Map<String, dynamic>> postMultipartMap(
    String path, {
    required FormData data,
  }) async {
    final response = await _guard(
      () => _dio.post<dynamic>(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      ),
    );
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return body;
    }
    throw const ApiException(message: 'Expected an object response.');
  }

  Future<Response<dynamic>> _guard(
    Future<Response<dynamic>> Function() action,
  ) async {
    try {
      return await action();
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic>
          ? (data['message']?.toString() ?? error.message ?? 'Request failed.')
          : (error.message ?? 'Request failed.');
      throw ApiException(
        message: message,
        statusCode: error.response?.statusCode,
      );
    }
  }
}

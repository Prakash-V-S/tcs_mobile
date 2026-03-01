import 'package:dio/dio.dart';
import '../constants/app_config.dart';
import 'token_storage.dart';

class ApiService {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiService({required TokenStorage tokenStorage, Dio? dio})
    : _tokenStorage = tokenStorage {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            responseType: ResponseType.json,
          ),
        );
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Append contextual headers required by backend middleware
          final companyType = await _tokenStorage.getCompanyType();
          final companyName = await _tokenStorage.getCompanyName();
          final username = await _tokenStorage.getUsername();

          if (companyType != null && companyType.isNotEmpty) {
            options.headers['company_type'] = companyType;
          }
          if (companyName != null && companyName.isNotEmpty) {
            options.headers['company_name'] = companyName;
          }
          if (username != null && username.isNotEmpty) {
            options.headers['user'] = username;
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _handleLogout();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _tokenStorage.clearToken();
    // TODO: Implement navigation to the login screen using your routing solution.
    // For example, triggering a global state change using Riverpod, Provider, or a GlobalNavigatorKey.
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String errorMessage = 'Unexpected error occurred.';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Connection timed out.';
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        switch (statusCode) {
          case 400:
            errorMessage = 'Bad request.';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 403:
            errorMessage = 'Access denied.';
            break;
          case 404:
            errorMessage = 'Resource not found.';
            break;
          case 500:
            errorMessage = 'Internal server error.';
            break;
          default:
            errorMessage = 'Server error: $statusCode.';
        }
      }

      // Try to parse error message from API response based on the required JSON format:
      // {
      //   success: false,
      //   message: string,
      //   error?: string
      // }
      if (error.response?.data != null &&
          error.response!.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        if (data.containsKey('message') && data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data.containsKey('error') && data['error'] != null) {
          errorMessage = data['error'].toString();
        }
      }
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'No Internet connection.';
    }

    return Exception(errorMessage);
  }
}

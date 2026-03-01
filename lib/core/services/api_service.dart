import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401) {
          await _handleLogout();
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate to login screen or perform logout logic
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: jsonEncode(data));
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: jsonEncode(data));
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.delete(endpoint, data: jsonEncode(data));
      return response.data;
    } on DioError catch (e) {
      _handleError(e);
    }
  }

  void _handleError(DioError error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 401:
          throw Exception('Unauthorized');
        case 403:
          throw Exception('Access Denied');
        case 500:
          throw Exception('Server Error');
        default:
          throw Exception(error.response!.data['message'] ?? 'Unknown Error');
      }
    } else {
      throw Exception('Network Error');
    }
  }
}

class AppConfig {
  static const String baseUrl = 'http://192.168.0.115:8090';
}
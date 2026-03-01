import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../model/login_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post('/login', data: request.toJson());

      // Parse the response directly. If 'token' is present, the login is successful
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('token') &&
            responseData['token'] != null) {
          return LoginResponse.fromJson(responseData);
        } else {
          throw Exception(
            responseData['message'] ?? 'Invalid email or password',
          );
        }
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network Error');
    } catch (e) {
      rethrow;
    }
  }
}

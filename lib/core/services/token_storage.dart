import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<bool> saveToken(String token);
  Future<String?> getToken();
  Future<bool> clearToken();
  Future<bool> saveUserRole(String role);
  Future<String?> getUserRole();
}

class TokenStorageImpl implements TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';

  @override
  Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  @override
  Future<bool> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    return await prefs.remove(_tokenKey);
  }

  @override
  Future<bool> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_roleKey, role);
  }

  @override
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }
}

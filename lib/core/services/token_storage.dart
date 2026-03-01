import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<bool> saveToken(String token);
  Future<String?> getToken();
  Future<bool> clearToken();
  Future<bool> saveUserRole(String role);
  Future<String?> getUserRole();
  Future<bool> saveUserId(String id);
  Future<String?> getUserId();
  Future<bool> saveCompanyName(String name);
  Future<String?> getCompanyName();
  Future<bool> saveCompanyType(String type);
  Future<String?> getCompanyType();
  Future<bool> saveUsername(String username);
  Future<String?> getUsername();
}

class TokenStorageImpl implements TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _companyNameKey = 'company_name';
  static const String _companyTypeKey = 'company_type';
  static const String _usernameKey = 'user_name';

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
    await prefs.remove(_companyNameKey);
    await prefs.remove(_companyTypeKey);
    await prefs.remove(_usernameKey);
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

  @override
  Future<bool> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_userIdKey, id);
  }

  @override
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  @override
  Future<bool> saveCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_companyNameKey, name);
  }

  @override
  Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyNameKey);
  }

  @override
  Future<bool> saveCompanyType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_companyTypeKey, type);
  }

  @override
  Future<String?> getCompanyType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyTypeKey);
  }

  @override
  Future<bool> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_usernameKey, username);
  }

  @override
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }
}

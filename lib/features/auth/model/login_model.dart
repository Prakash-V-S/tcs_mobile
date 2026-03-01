class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;
  final String deviceType;

  LoginRequest({
    required this.username,
    required this.password,
    this.rememberMe = false,
    this.deviceType = "WEB",
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'rememberMe': rememberMe,
        'deviceType': deviceType,
      };
}

class LoginResponse {
  final String token;
  final String refreshToken;
  final User user;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class User {
  final String id;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String companyName;
  final bool isAdmin;
  final List<String> moduleAccess;

  User({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.companyName,
    required this.isAdmin,
    required this.moduleAccess,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      isAdmin: json['isAdmin'] ?? false,
      moduleAccess: List<String>.from(json['moduleAccess'] ?? []),
    );
  }

  // Helper method to resolve equivalent role to string since role
  // is dependent purely on admin and module flags from the response.
  String get role => isAdmin ? 'admin' : 'user';
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/api_service.dart';
import 'core/services/token_storage.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';
import 'features/auth/view/login_screen.dart';

void main() {
  runApp(const TcsMobileApp());
}

class TcsMobileApp extends StatelessWidget {
  const TcsMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<TokenStorage>(
          create: (_) => TokenStorageImpl(),
        ),
        ProxyProvider<TokenStorage, ApiService>(
          update: (_, tokenStorage, __) => ApiService(tokenStorage: tokenStorage),
        ),
        ProxyProvider<ApiService, AuthService>(
          update: (_, apiService, __) => AuthService(apiService),
        ),
        
        // ViewModels
        ChangeNotifierProxyProvider2<AuthService, TokenStorage, LoginViewModel>(
          create: (context) => LoginViewModel(
            context.read<AuthService>(),
            context.read<TokenStorage>(),
          ),
          update: (_, authService, tokenStorage, previous) =>
              previous ?? LoginViewModel(authService, tokenStorage),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CTCS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          // TODO: Implement Dashboard Feature
          '/dashboard': (context) => const Scaffold(
                body: Center(
                  child: Text('Dashboard (Coming Soon)'),
                ),
              ),
        },
      ),
    );
  }
}
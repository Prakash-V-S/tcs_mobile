import 'package:flutter/material.dart';

void main() {
  runApp(const TcsMobileApp());
}

class TcsMobileApp extends StatelessWidget {
  const TcsMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('TCS Mobile App'),
        ),
      ),
    );
  }
}
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inside_casa_app/theme/appTheme.dart';
import 'package:inside_casa_app/user-interface/auth/login/LoginScreen.dart';

void main() {
  runApp(const InsideCasaApp());
}

class InsideCasaApp extends StatelessWidget {
  const InsideCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inside Casa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), // On commence par le splash screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/LogoInsideCasa.png', height: 140),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFFfdcf00)),
          ],
        ),
      ),
    );
  }
}

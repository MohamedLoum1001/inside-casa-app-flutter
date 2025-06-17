// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:inside_casa_app/theme/appTheme.dart';
import 'package:inside_casa_app/user-interface/auth/login/LoginScreen.dart';
import 'package:inside_casa_app/user-interface/screens/SplashScreen.dart';
import 'package:inside_casa_app/user-interface/screens/homeScreen.dart';

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
      // Le splash screen est la page d'accueil
      initialRoute: '/login',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/homeCustomer': (context) => const HomeScreen(),
        // '/homePartner': (context) => const HomePartnerScreen(),
      },
    );
  }
}

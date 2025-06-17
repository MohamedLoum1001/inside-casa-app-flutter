// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/services/authService.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Affiche le splash screen pendant 3 secondes
    await Future.delayed(const Duration(seconds: 3));

    final token = await _authService.getToken();

    if (token == null) {
      // Pas de token => page de connexion
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Vérifie que le token JWT a bien 3 parties
    final parts = token.split('.');
    if (parts.length != 3) {
      // Token invalide => suppression et retour login
      await _authService.deleteToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final payloadBase64 = parts[1];
      final normalized = base64.normalize(payloadBase64);
      final payloadString = utf8.decode(base64.decode(normalized));
      final payload = jsonDecode(payloadString);

      final role = payload['role'];
      if (role == 'customer') {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/homeCustomer');
      } else if (role == 'partner') {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/homePartner');
      } else {
        // Rôle inconnu => suppression token et retour login
        await _authService.deleteToken();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // En cas d'erreur dans le décodage, suppression token et retour login
      await _authService.deleteToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'images/LogoInsideCasa.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

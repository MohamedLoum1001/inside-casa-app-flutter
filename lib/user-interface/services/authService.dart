import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inside_casa_app/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../config/constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return {'success': true, 'token': data['token']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur de connexion'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullname,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'password': password,
        'phone': '0000000000',
        'role': role,
        'description': ''
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur d\'inscription'};
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

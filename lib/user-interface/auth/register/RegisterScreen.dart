import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String selectedRole = 'Utilisateur';

  final storage = const FlutterSecureStorage();

  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final RegExp phoneRegex = RegExp(r'^0[5-7][0-9]{8}$');

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final userData = {
      'fullname': fullnameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': '+212${phoneCtrl.text.trim().substring(1)}',
      'password': passwordCtrl.text.trim(),
      'role': selectedRole == 'Utilisateur' ? 'customer' : 'partner',
    };

    try {
      final response = await http.post(
        Uri.parse('https://insidecasa.me/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final userId = data['userId'];
        final token = data['token'];

        // Stockage local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', userId);
        await prefs.setString('fullname', userData['fullname'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('phone', userData['phone'] ?? '');
        await prefs.setString('role', userData['role'] ?? '');

        // Stockage sécurisé du token
        if (token != null) {
          await storage.write(key: 'jwt_token', value: token);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie ✅")),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erreur d\'inscription')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  void dispose() {
    fullnameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset("images/LogoInsideCasa.png", height: 130),
                const SizedBox(height: 12),
                Text("Créer un compte ✨",
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Inscris-toi pour découvrir Casablanca !",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 20),

                // Rôle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 'Utilisateur', child: Text('Utilisateur')),
                      DropdownMenuItem(
                          value: 'Partenaire', child: Text('Partenaire')),
                    ],
                    onChanged: (value) => setState(() => selectedRole = value!),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: fullnameCtrl,
                  decoration: _inputDecoration("Nom complet", Icons.person),
                  validator: (value) =>
                      value!.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: emailCtrl,
                  decoration: _inputDecoration("Email", Icons.email),
                  validator: (value) =>
                      !emailRegex.hasMatch(value!) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("+212",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: _inputDecoration("Téléphone", Icons.phone)
                            .copyWith(counterText: ""),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le téléphone est requis";
                          }
                          if (!phoneRegex.hasMatch(value)) {
                            return "Format: 05/06/07XXXXXXXX";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: passwordCtrl,
                  obscureText: !showPassword,
                  decoration:
                      _inputDecoration("Mot de passe", Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Minimum 6 caractères' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: confirmCtrl,
                  obscureText: !showConfirmPassword,
                  decoration: _inputDecoration(
                          "Confirmer mot de passe", Icons.lock_outline)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => showConfirmPassword = !showConfirmPassword),
                    ),
                  ),
                  validator: (value) => value != passwordCtrl.text
                      ? 'Mots de passe différents'
                      : null,
                ),
                const SizedBox(height: 24),

                // Bouton s'inscrire
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isLoading ? Colors.grey : const Color(0xFFfdcf00),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("S'inscrire",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton se connecter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff5609),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Se connecter",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

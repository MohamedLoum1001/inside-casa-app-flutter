// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  String selectedRole = 'Utilisateur';
  bool isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final role = selectedRole == 'Utilisateur' ? 'customer' : 'partner';

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://insidecasa.me/api/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullname": fullnameCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "phone": phoneCtrl.text.trim(),
          "password": passwordCtrl.text,
          "role": role,
        }),
      );

      if (response.statusCode == 201) {
        showToast("Inscription réussie !");
        Navigator.pop(context);
      } else {
        final body = jsonDecode(response.body);
        showToast(body["message"] ?? "Erreur d'inscription");
      }
    } catch (e) {
      showToast("Erreur de connexion");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset("images/LogoInsideCasa.png", height: 130),
                Text(
                  "Créer un compte ✨",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Inscris-toi pour découvrir Casablanca !",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildDropdown(),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: fullnameCtrl,
                        hintText: "Prénom & Nom",
                        icon: Icons.person_outline,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Nom requis"
                                : null,
                      ),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: emailCtrl,
                        hintText: "Adresse email",
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email requis";
                          }
                          final emailRegex =
                              RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                          return emailRegex.hasMatch(value.trim())
                              ? null
                              : "Email invalide";
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: phoneCtrl,
                        hintText: "Téléphone",
                        icon: Icons.phone,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? "Téléphone requis"
                                : null,
                      ),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: passwordCtrl,
                        hintText: "Mot de passe",
                        obscureText: !showPassword,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isVisible: showPassword,
                        toggleVisibility: () =>
                            setState(() => showPassword = !showPassword),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Mot de passe requis";
                          }
                          if (value.length < 6) {
                            return "Minimum 6 caractères";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: confirmCtrl,
                        hintText: "Confirmer le mot de passe",
                        obscureText: !showConfirmPassword,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isVisible: showConfirmPassword,
                        toggleVisibility: () => setState(
                            () => showConfirmPassword = !showConfirmPassword),
                        validator: (value) => value != passwordCtrl.text
                            ? "Les mots de passe ne correspondent pas"
                            : null,
                      ),
                      const SizedBox(height: 13),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFfdcf00),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  "S'inscrire",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFff5609),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Se connecter",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: DropdownButton<String>(
        value: selectedRole,
        isExpanded: true,
        underline: const SizedBox(),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        items: const [
          DropdownMenuItem(value: 'Utilisateur', child: Text('Utilisateur')),
          DropdownMenuItem(value: 'Partenaire', child: Text('Partenaire')),
        ],
        onChanged: (value) => setState(() => selectedRole = value!),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
      ),
    );
  }
}

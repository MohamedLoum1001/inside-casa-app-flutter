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
  final fullnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  String selectedRole = 'customer';

  @override
  void dispose() {
    fullnameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> registerUser() async {
    final String fullname = fullnameCtrl.text.trim();
    final String email = emailCtrl.text.trim();
    final String password = passwordCtrl.text.trim();
    final String confirmPassword = confirmCtrl.text.trim();
    final String phone = phoneCtrl.text.trim();

    if ([fullname, email, password, confirmPassword, phone].any((e) => e.isEmpty)) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Les mots de passe ne correspondent pas.");
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("https://localhost:5000/api/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullname": fullname,
          "email": email,
          "password": password,
          "phone": phone,
          "role": selectedRole,
          "description": ""
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        _showMessage("Inscription réussie !");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = jsonDecode(response.body);
        _showMessage("Erreur : ${error['message'] ?? 'Inscription échouée.'}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Erreur réseau : ${e.toString()}");
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool toggleVisible = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: toggleVisible
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggle,
              )
            : null,
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset("images/LogoInsideCasa.png", height: 130),
              const SizedBox(height: 20),

              Text(
                "Créer un compte",
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Rôle",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Utilisateur')),
                  DropdownMenuItem(value: 'partner', child: Text('Partenaire')),
                ],
                onChanged: (value) {
                  setState(() => selectedRole = value!);
                },
              ),
              const SizedBox(height: 12),

              buildTextField(controller: fullnameCtrl, label: "Nom complet", icon: Icons.person),
              const SizedBox(height: 12),

              buildTextField(controller: emailCtrl, label: "Email", icon: Icons.email),
              const SizedBox(height: 12),

              buildTextField(controller: phoneCtrl, label: "Téléphone", icon: Icons.phone),
              const SizedBox(height: 12),

              buildTextField(
                controller: passwordCtrl,
                label: "Mot de passe",
                icon: Icons.lock,
                obscure: !showPassword,
                toggleVisible: true,
                onToggle: () => setState(() => showPassword = !showPassword),
              ),
              const SizedBox(height: 12),

              buildTextField(
                controller: confirmCtrl,
                label: "Confirmer le mot de passe",
                icon: Icons.lock_outline,
                obscure: !showConfirmPassword,
                toggleVisible: true,
                onToggle: () => setState(() => showConfirmPassword = !showConfirmPassword),
              ),
              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFfdcf00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "S'inscrire",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text("Déjà un compte ? Se connecter", style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

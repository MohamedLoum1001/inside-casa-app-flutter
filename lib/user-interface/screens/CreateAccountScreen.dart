// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Simuler enregistrement utilisateur
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte modifié avec succès ✅")),
        );
        Navigator.pop(context); // Retour à la page précédente
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifer votre compte"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1,
                    size: 80, color: Color(0xFFfdcf00)),
                const SizedBox(height: 12),
                Text(
                  "Bienvenue 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Remplis les champs pour créer ton compte",
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // Nom
                TextFormField(
                  controller: nameCtrl,
                  decoration: _inputDecoration("Nom complet", Icons.person),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Nom requis" : null,
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      _inputDecoration("Adresse email", Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "L'email est requis";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(value.trim())) {
                      return "Email invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Mot de passe
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: !showPassword,
                  decoration:
                      _inputDecoration("Mot de passe", Icons.lock_outline)
                          .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le mot de passe est requis";
                    }
                    if (value.length < 6) {
                      return "Mot de passe trop court";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Bouton "Créer un compte"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFfdcf00),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "Créer le compte",
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
        ),
      ),
    );
  }
}

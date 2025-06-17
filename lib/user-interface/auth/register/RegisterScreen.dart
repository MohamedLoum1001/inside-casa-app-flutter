import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final prenomCtrl = TextEditingController();
  final nomCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  String selectedRole = 'Utilisateur';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour toute la page
      body: Container(
        color: Colors.white, // Fond blanc pour le body aussi
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

                // Sélecteur de rôle
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Utilisateur',
                        child: Text('Utilisateur'),
                      ),
                      DropdownMenuItem(
                        value: 'Partenaire',
                        child: Text('Partenaire'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Prénom
                _buildInput(
                  controller: prenomCtrl,
                  hintText: "Prénom & Nom",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 8),

                // Email
                _buildInput(
                  controller: emailCtrl,
                  hintText: "Adresse email",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 8),

                // Mot de passe
                _buildInput(
                  controller: passwordCtrl,
                  hintText: "Mot de passe",
                  obscureText: !showPassword,
                  icon: Icons.lock_outline,
                  toggleVisibility: () {
                    setState(() => showPassword = !showPassword);
                  },
                  isPassword: true,
                  isVisible: showPassword,
                ),
                const SizedBox(height: 8),

                // Confirmation
                _buildInput(
                  controller: confirmCtrl,
                  hintText: "Confirmer le mot de passe",
                  obscureText: !showConfirmPassword,
                  icon: Icons.lock_outline,
                  toggleVisibility: () {
                    setState(() => showConfirmPassword = !showConfirmPassword);
                  },
                  isPassword: true,
                  isVisible: showConfirmPassword,
                ),
                const SizedBox(height: 13),

                // ...existing code...
                const SizedBox(height: 13),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFfdcf00), // Jaune
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
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
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFff5609), // Orange
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
// ...existing code...
              ],
            ),
          ),
        ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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

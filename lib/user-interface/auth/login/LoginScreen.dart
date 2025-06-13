import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inside_casa_app/user-interface/auth/register/RegisterScreen.dart';
import 'package:inside_casa_app/user-interface/screens/PartnerHomeScreen.dart';
import 'package:inside_casa_app/user-interface/screens/homeScreen.dart';
import 'package:inside_casa_app/user-interface/services/authService.dart';
import 'package:inside_casa_app/user-interface/widgets/InputField.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    final response = await AuthService.login(
      emailCtrl.text.trim(),
      passwordCtrl.text.trim(),
    );

    setState(() => isLoading = false);

    if (response['success']) {
      final token = response['token'];
      final prefs = await SharedPreferences.getInstance();
      final role = response['role'] ?? 'customer'; // fallback

      await prefs.setString('token', token);
      await prefs.setString('role', role);

      if (role == 'partner') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const PartnerHomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      Fluttertoast.showToast(
        msg: response['message'] ?? 'Erreur de connexion',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("images/LogoInsideCasa.png", height: 120),
                const SizedBox(height: 24),
                Text("Bienvenue 👋",
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 8),
                Text("Connecte-toi pour explorer Casablanca !",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    )),
                const SizedBox(height: 30),
                InputField(
                  controller: emailCtrl,
                  hintText: "Adresse email",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: passwordCtrl,
                  hintText: "Mot de passe",
                  icon: Icons.lock_outline,
                  obscureText: !showPassword,
                  isPassword: true,
                  toggleVisibility: () {
                    setState(() => showPassword = !showPassword);
                  },
                  isVisible: showPassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFfdcf00),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text("Connexion",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Créer un compte",
                    style: GoogleFonts.poppins(color: Colors.black),
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

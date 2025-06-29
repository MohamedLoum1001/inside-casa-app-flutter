// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({super.key});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _expiryDate = TextEditingController();
  final _cvc = TextEditingController();
  final _name = TextEditingController();
  bool isLoading = false;

  void _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await Future.delayed(
        const Duration(seconds: 2)); // Simulation délai backend

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Paiement Stripe simulé avec succès")),
    );

    Navigator.pop(context); // Retour après paiement
  }

  @override
  void dispose() {
    _cardNumber.dispose();
    _expiryDate.dispose();
    _cvc.dispose();
    _name.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement par carte"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.credit_card, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                "Entrez les détails de votre carte bancaire",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Numéro de carte
              TextFormField(
                controller: _cardNumber,
                keyboardType: TextInputType.number,
                decoration:
                    _inputDecoration("Numéro de carte", Icons.credit_card),
                validator: (value) => value != null && value.length >= 16
                    ? null
                    : "Numéro invalide",
              ),
              const SizedBox(height: 16),

              // Date d'expiration
              TextFormField(
                controller: _expiryDate,
                decoration:
                    _inputDecoration("Expiration (MM/AA)", Icons.date_range),
                validator: (value) =>
                    RegExp(r'^\d{2}/\d{2}$').hasMatch(value ?? "")
                        ? null
                        : "Format invalide",
              ),
              const SizedBox(height: 16),

              // CVC
              TextFormField(
                controller: _cvc,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("CVC", Icons.lock),
                validator: (value) =>
                    value != null && value.length >= 3 ? null : "CVC invalide",
              ),
              const SizedBox(height: 16),

              // Nom sur la carte
              TextFormField(
                controller: _name,
                decoration: _inputDecoration("Nom sur la carte", Icons.person),
                validator: (value) => value != null && value.trim().isNotEmpty
                    ? null
                    : "Nom requis",
              ),
              const SizedBox(height: 30),

              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitPayment,
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
                          "Payer maintenant",
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
    );
  }
}

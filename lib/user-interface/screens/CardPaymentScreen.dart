// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/PaymentValidationScreen.dart';


class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentValidationScreen(
            onPaymentConfirmed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Paiement validé avec succès !")),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.credit_card, size: 80, color: Color(0xFFfdcf00)),
              const SizedBox(height: 16),
              const Text(
                "Entrez les informations de votre carte",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // Numéro de carte
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Numéro de carte",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.length < 16) {
                    return "Veuillez entrer un numéro valide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date d'expiration
              TextFormField(
                controller: _expiryDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: "Date d'expiration (MM/AA)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return "Format invalide. Utilisez MM/AA";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CVC
              TextFormField(
                controller: _cvcController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "CVC",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return "CVC invalide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nom du titulaire
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom du titulaire",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nom requis";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    "Payer avec PayPal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _validateAndProceed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

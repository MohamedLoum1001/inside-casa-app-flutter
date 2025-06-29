import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/SelectPaymentMethodScreen.dart';

class PaymentValidationScreen extends StatelessWidget {
  final VoidCallback onPaymentConfirmed;

  const PaymentValidationScreen({super.key, required this.onPaymentConfirmed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validation du paiement"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                "Votre réservation est prête à être payée.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Cliquez sur le bouton ci-dessous pour valider et finaliser votre paiement.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    "Valider le paiement",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Redirection vers la page de sélection du mode de paiement
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectPaymentMethodScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

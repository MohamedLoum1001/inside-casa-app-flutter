// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/StripePaymentScreen.dart';
import 'package:inside_casa_app/user-interface/screens/MobilePaymentScreen.dart';

class SelectPaymentMethodScreen extends StatelessWidget {
  const SelectPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisissez le mode de paiement"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Veuillez choisir un mode de paiement :",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.deepPurple),
            title: const Text("Paiement par carte (Stripe/PayPal)"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StripePaymentScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone_android, color: Colors.orange),
            title: const Text("Paiement mobile local"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MobilePaymentScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

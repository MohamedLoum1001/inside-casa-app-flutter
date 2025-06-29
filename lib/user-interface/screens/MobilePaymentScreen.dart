// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/InwiMoneyForm.dart';
import 'package:inside_casa_app/user-interface/screens/MobicashForm.dart';
import 'package:inside_casa_app/user-interface/screens/OrangeMoneyForm.dart';
// import 'package:inside_casa_app/user-interface/payments/OrangeMoneyForm.dart';
// import 'package:inside_casa_app/user-interface/payments/InwiMoneyForm.dart';
// import 'package:inside_casa_app/user-interface/payments/MobicashForm.dart';

class MobilePaymentScreen extends StatelessWidget {
  const MobilePaymentScreen({super.key});

  void _navigateToOperatorForm(BuildContext context, String operator) {
    Widget formScreen;

    switch (operator) {
      case "Orange":
        formScreen = const OrangeMoneyForm();
        break;
      case "Inwi":
        formScreen = const InwiMoneyForm();
        break;
      case "Mobicash":
        formScreen = const MobicashForm();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => formScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement mobile local"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Choisissez votre opérateur mobile :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.phone_android, color: Colors.orange),
            title: const Text("Orange Money"),
            onTap: () => _navigateToOperatorForm(context, "Orange"),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android, color: Colors.blue),
            title: const Text("Inwi Money"),
            onTap: () => _navigateToOperatorForm(context, "Inwi"),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android, color: Colors.green),
            title: const Text("Maroc Telecom Mobicash"),
            onTap: () => _navigateToOperatorForm(context, "Mobicash"),
          ),
        ],
      ),
    );
  }
}

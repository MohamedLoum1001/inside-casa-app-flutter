import 'package:flutter/material.dart';

class MobilePaymentScreen extends StatefulWidget {
  const MobilePaymentScreen({super.key});

  @override
  State<MobilePaymentScreen> createState() => _MobilePaymentScreenState();
}

class _MobilePaymentScreenState extends State<MobilePaymentScreen> {
  final _phoneController = TextEditingController();

  void _simulatePayment() {
    final phone = _phoneController.text;
    if (phone.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Paiement en cours..."),
        content: Text("Paiement mobile simulé pour le numéro : $phone"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement Mobile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone",
                prefixText: "+221 ",
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _simulatePayment,
              icon: const Icon(Icons.payment),
              label: const Text("Payer"),
            )
          ],
        ),
      ),
    );
  }
}

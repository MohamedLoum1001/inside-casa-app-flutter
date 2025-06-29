import 'package:flutter/material.dart';

class InwiMoneyForm extends StatelessWidget {
  const InwiMoneyForm({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Inwi Money"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Entrez votre numéro Inwi Money pour procéder au paiement.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Numéro Inwi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return "Numéro invalide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Paiement Inwi initié ✅")),
                      );
                    }
                  },
                  child: const Text("Payer maintenant"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

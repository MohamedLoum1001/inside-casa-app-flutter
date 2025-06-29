import 'package:flutter/material.dart';

class OrangeMoneyForm extends StatelessWidget {
  const OrangeMoneyForm({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Orange Money"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Entrez votre numéro Orange Money pour procéder au paiement.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Numéro Orange",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Paiement Orange initié ✅")),
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

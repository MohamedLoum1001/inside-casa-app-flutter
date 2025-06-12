import 'package:flutter/material.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: "Nom")),
            const TextField(decoration: InputDecoration(labelText: "Email")),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Mot de passe")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique de création
              },
              child: const Text("Créer le compte"),
            )
          ],
        ),
      ),
    );
  }
}

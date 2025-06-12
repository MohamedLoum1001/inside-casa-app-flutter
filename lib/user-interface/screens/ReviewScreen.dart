import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Avis & Notes")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: "Votre avis")),
            const SizedBox(height: 10),
            const Text("Note : ⭐⭐⭐⭐☆"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Sauvegarder l’avis
              },
              child: const Text("Envoyer"),
            )
          ],
        ),
      ),
    );
  }
}

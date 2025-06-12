import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.share),
        label: const Text("Partager Inside Casa"),
        onPressed: () {
          Share.share("Découvrez Inside Casa et réservez vos activités locales ! 🔥");
        },
      ),
    );
  }
}

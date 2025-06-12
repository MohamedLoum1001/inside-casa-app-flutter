import 'package:flutter/material.dart';

class ReservationsHistoryScreen extends StatelessWidget {
  const ReservationsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des réservations")),
      body: const Center(
        child: Text("Historique de vos réservations"),
      ),
    );
  }
}

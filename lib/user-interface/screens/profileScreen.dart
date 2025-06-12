// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/CardPaymentScreen.dart';
import 'package:inside_casa_app/user-interface/screens/MobilePaymentScreen.dart';
// import 'CardPaymentScreen.dart';
// import 'MobilePaymentScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFfdcf00)),
            onPressed: () {
              // TODO: Naviguer vers la page d'édition du profil
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFfdcf00),
              child: const Icon(Icons.person, size: 55, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              "Nom Prénom",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "email@email.com",
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 28),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFff5609)),
            title: const Text("Mes favoris"),
            onTap: () {
              // TODO: Aller à la page favoris
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF2575FC)),
            title: const Text("Historique des réservations"),
            onTap: () {
              // TODO: Aller à la page réservations
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Color(0xFFfdcf00)),
            title: const Text("Mes avis & notes"),
            onTap: () {
              // TODO: Aller à la page avis
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Color(0xFF2575FC)),
            title: const Text("Partager sur les réseaux sociaux"),
            onTap: () {
              // TODO: Logique de partage
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFFff5609)),
            title: const Text("Notifications"),
            onTap: () {
              // TODO: Paramètres notifications
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.credit_card, color: Color(0xFFfdcf00)),
            title: const Text("Paiement par carte"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardPaymentScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_android, color: Color(0xFF2575FC)),
            title: const Text("Paiement mobile local"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MobilePaymentScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion"),
            onTap: () {
              // TODO: Logique de déconnexion
            },
          ),
        ],
      ),
    );
  }
}

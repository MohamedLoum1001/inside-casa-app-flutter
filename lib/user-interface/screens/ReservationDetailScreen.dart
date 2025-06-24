// ReservationDetailScreen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;
  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? details;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("Utilisateur non connecté");

      final res = await http.get(
        Uri.parse('https://insidecasa.me/api/reservations/${widget.reservationId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        details = jsonDecode(res.body);
      } else {
        error = "Erreur ${res.statusCode}";
      }
    } catch (e) {
      error = "Erreur : $e";
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détail réservation")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text("ID: ${details!['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Activité: ${details!['activity']?['title'] ?? 'N/A'}"),
                      Text("Date: ${details!['date'] ?? 'N/A'}"),
                      Text("Statut: ${details!['status'] ?? 'N/A'}"),
                      Text("Utilisateur: ${details!['user']?['fullname'] ?? 'N/A'}"),
                      // Ajoute d'autres champs au besoin
                    ],
                  ),
                ),
    );
  }
}

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inside_casa_app/user-interface/screens/EvenementsDetailScreen.dart';

class EvenementsScreen extends StatefulWidget {
  final String filter;

  const EvenementsScreen({super.key, this.filter = ''});

  @override
  State<EvenementsScreen> createState() => _EvenementsScreenState();
}

class _EvenementsScreenState extends State<EvenementsScreen> {
  final storage = FlutterSecureStorage();
  bool isLoading = true;
  String error = '';
  List<dynamic> evenements = [];

  @override
  void initState() {
    super.initState();
    fetchEvenements();
  }

  Future<void> fetchEvenements() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          error = "Token introuvable. Veuillez vous reconnecter.";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://insidecasa.me/api/events'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          evenements = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Erreur serveur : ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Erreur réseau : ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
          child: Text(error, style: const TextStyle(color: Colors.red)));
    }

    if (evenements.isEmpty) {
      return const Center(child: Text("Aucun événement disponible."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evenements.length,
      itemBuilder: (context, index) {
        final event = evenements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            title: Text(
              "Événement #${event['id'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Date: ${event['event_date'] ?? 'N/A'}"),
                Text(
                    "Heure: ${event['start_time'] ?? 'N/A'} - ${event['end_time'] ?? 'N/A'}"),
                Text("Capacité: ${event['capacity'] ?? 'N/A'}"),
                Text("Places restantes: ${event['remaining_places'] ?? 'N/A'}"),
                Text("ID Activité: ${event['activity_id'] ?? 'N/A'}"),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EvenementsDetailScreen(eventId: event['id'] ?? 0),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

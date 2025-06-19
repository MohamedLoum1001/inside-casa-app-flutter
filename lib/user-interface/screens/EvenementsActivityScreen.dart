// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EvenementsActivityScreen extends StatefulWidget {
  final int activityId;

  const EvenementsActivityScreen({super.key, required this.activityId});

  @override
  State<EvenementsActivityScreen> createState() => _EvenementsActivityScreenState();
}

class _EvenementsActivityScreenState extends State<EvenementsActivityScreen> {
  final storage = FlutterSecureStorage();

  bool isLoading = true;
  String error = '';
  List<dynamic> evenements = [];

  @override
  void initState() {
    super.initState();
    fetchEvenementsByActivity();
  }

  Future<void> fetchEvenementsByActivity() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          error = "Token introuvable. Veuillez vous reconnecter.";
          isLoading = false;
        });
        return;
      }

      final url = 'https://insidecasa.me/api/events/activity/${widget.activityId}';

      final response = await http.get(
        Uri.parse(url),
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
      return Scaffold(
        appBar: AppBar(title: Text('Événements de l\'activité')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Événements de l\'activité')),
        body: Center(child: Text(error, style: TextStyle(color: Colors.red))),
      );
    }

    if (evenements.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Événements de l\'activité')),
        body: Center(child: Text("Aucun événement trouvé pour cette activité.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Événements de l\'activité')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: evenements.length,
        itemBuilder: (context, index) {
          final event = evenements[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(event['title'] ?? 'Sans titre',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event['description'] != null)
                    Text(event['description']),
                  SizedBox(height: 4),
                  Text("Date : ${event['event_date'] ?? 'N/A'}"),
                  Text("Heure : ${event['start_time'] ?? 'N/A'} - ${event['end_time'] ?? 'N/A'}"),
                  Text("Capacité : ${event['capacity'] ?? 'N/A'}"),
                  Text("Places restantes : ${event['remaining_places'] ?? 'N/A'}"),
                ],
              ),
              onTap: () {
                // Ici, tu peux par exemple naviguer vers le détail de l'événement si besoin
              },
            ),
          );
        },
      ),
    );
  }
}

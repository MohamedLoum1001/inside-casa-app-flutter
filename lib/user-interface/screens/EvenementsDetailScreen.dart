// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EvenementsDetailScreen extends StatefulWidget {
  final int eventId;

  const EvenementsDetailScreen({super.key, required this.eventId});

  @override
  State<EvenementsDetailScreen> createState() => _EvenementsDetailScreenState();
}

class _EvenementsDetailScreenState extends State<EvenementsDetailScreen> {
  final storage = FlutterSecureStorage();

  bool isLoading = true;
  String error = '';

  Map<String, dynamic>? event;
  List<dynamic> activities = [];
  bool isLoadingActivities = false;
  String activitiesError = '';

  @override
  void initState() {
    super.initState();
    fetchEventDetail();
  }

  Future<void> fetchEventDetail() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          error = "Token introuvable. Veuillez vous reconnecter.";
          isLoading = false;
        });
        return;
      }

      final url = 'https://insidecasa.me/api/events/${widget.eventId}';

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
          event = data;
          isLoading = false;
        });

        // Si event a une activité liée, on récupère les activités associées
        if (event != null && event!['activity_id'] != null) {
          fetchActivities(event!['activity_id'], token);
        } else {
          setState(() {
            activities = [];
          });
        }
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

  Future<void> fetchActivities(int activityId, String token) async {
    setState(() {
      isLoadingActivities = true;
      activitiesError = '';
    });

    try {
      final url = 'https://insidecasa.me/api/events/activity/$activityId';

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
          activities = data;
          isLoadingActivities = false;
        });
      } else {
        setState(() {
          activitiesError = "Erreur serveur activités : ${response.statusCode}";
          isLoadingActivities = false;
        });
      }
    } catch (e) {
      setState(() {
        activitiesError = "Erreur réseau activités : ${e.toString()}";
        isLoadingActivities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Détail de l\'événement')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Détail de l\'événement')),
        body: Center(child: Text(error, style: TextStyle(color: Colors.red))),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Détail de l\'événement')),
        body: Center(child: Text("Événement introuvable.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(event!['title'] ?? 'Détail de l\'événement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (event!['description'] != null)
              Text(event!['description'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.grey),
                SizedBox(width: 8),
                Text("Date : ${event!['event_date'] ?? 'N/A'}"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 8),
                Text("De ${event!['start_time'] ?? 'N/A'} à ${event!['end_time'] ?? 'N/A'}"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group, color: Colors.grey),
                SizedBox(width: 8),
                Text("Capacité : ${event!['capacity'] ?? 'N/A'}"),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_seat, color: Colors.grey),
                SizedBox(width: 8),
                Text("Places restantes : ${event!['remaining_places'] ?? 'N/A'}"),
              ],
            ),
            SizedBox(height: 24),
            Divider(),
            Text("Activités liées",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            if (isLoadingActivities)
              Center(child: CircularProgressIndicator())
            else if (activitiesError.isNotEmpty)
              Text(activitiesError, style: TextStyle(color: Colors.red))
            else if (activities.isEmpty)
              Center(
                child: Text("Aucune activité liée à cet événement.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              )
            else
              ...activities.map((activity) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text(activity['title'] ?? 'Sans titre'),
                    subtitle: Text(activity['description'] ?? 'Pas de description'),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

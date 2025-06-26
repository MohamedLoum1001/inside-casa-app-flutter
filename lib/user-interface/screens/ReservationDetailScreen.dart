import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;
  final String jwtToken;

  const ReservationDetailScreen({
    super.key,
    required this.reservationId,
    required this.jwtToken,
  });

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  Map<String, dynamic>? reservation;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchReservationDetail();
  }

  Future<void> fetchReservationDetail() async {
    try {
      final response = await http.get(
        Uri.parse('https://insidecasa.me/api/reservations/${widget.reservationId}'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reservation = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Erreur ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Erreur : $e";
        isLoading = false;
      });
    }
  }

  String formatDate(String? date) {
    if (date == null) return "Date inconnue";
    try {
      return DateTime.parse(date).toLocal().toString().split(' ')[0];
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Réservation #${widget.reservationId}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : reservation == null
                  ? Center(child: Text("Aucune donnée"))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Text(
                            "ID Réservation : ${reservation!['id']}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(height: 12),
                          // Affichage des détails de l'activité si elle existe
                          ..._buildActivityDetails(reservation!['activity']),
                          SizedBox(height: 16),
                          Text("Nombre de personnes : ${reservation!['nombre_personnes'] ?? 'N/A'}"),
                          Text("Date : ${formatDate(reservation!['date'])}"),
                          Text("Statut : ${reservation!['status'] ?? 'N/A'}"),
                          SizedBox(height: 16),
                          Text(
                            "Prix unitaire : ${reservation!['activity'] != null ? (reservation!['activity']['price'] ?? '0') : '0'} MAD"
                          ),
                          Text(
                            "Prix total : ${(reservation!['nombre_personnes'] ?? 1) * (double.tryParse(reservation!['activity']?['price']?.toString() ?? '0') ?? 0)} MAD",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
    );
  }

  List<Widget> _buildActivityDetails(dynamic activity) {
    if (activity == null) {
      return [
        Text(
          "Activité supprimée ou non trouvée.",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ];
    }
    final location = activity['location'] ?? 'Non spécifié';
    final duration = activity['duration']?.toString() ?? 'Inconnue';
    final title = activity['title'] ?? 'Sans titre';
    final imageUrls = activity['image_urls'] as List<dynamic>? ?? [];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

    return [
      if (imageUrl != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
        ),
      SizedBox(height: 12),
      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      SizedBox(height: 8),
      Text("Lieu : $location"),
      Text("Durée : $duration minutes"),
    ];
  }
}
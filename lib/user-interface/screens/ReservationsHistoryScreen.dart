import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationDetailScreen.dart';

class ReservationsHistoryScreen extends StatefulWidget {
  const ReservationsHistoryScreen({super.key});

  @override
  State<ReservationsHistoryScreen> createState() =>
      _ReservationsHistoryScreenState();
}

class _ReservationsHistoryScreenState extends State<ReservationsHistoryScreen> {
  bool isLoading = true;
  List reservations = [];
  String? error;

  @override
  void initState() {
    super.initState();
    loadUserReservations();
  }

  Future<void> loadUserReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId =
          prefs.getInt('user_id'); // récupère l'ID de l'utilisateur connecté

      if (token == null || userId == null) {
        throw Exception("Utilisateur non connecté.");
      }

      final response = await http.get(
        Uri.parse('https://insidecasa.me/api/reservations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ✅ Filtrer les réservations faites uniquement par l'utilisateur connecté
        setState(() {
          reservations =
              List.from(data).where((r) => r['user_id'] == userId).toList();
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
        error = "Erreur: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique de mes réservations")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : reservations.isEmpty
                  ? const Center(child: Text("Aucune réservation trouvée."))
                  : ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (_, i) {
                        final r = reservations[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text("Réservation #${r['id']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Statut : ${r['status'] ?? 'N/A'}"),
                                Text("Date : ${r['date'] ?? 'N/A'}"),
                              ],
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReservationDetailScreen(
                                      reservationId: r['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

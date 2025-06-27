import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationsHistoryScreen extends StatefulWidget {
  final int userId;
  final String jwtToken;

  const ReservationsHistoryScreen({
    super.key,
    required this.userId,
    required this.jwtToken,
  });

  @override
  State<ReservationsHistoryScreen> createState() =>
      _ReservationsHistoryScreenState();
}

class _ReservationsHistoryScreenState extends State<ReservationsHistoryScreen> {
  List<Map<String, dynamic>> reservationsWithActivity = [];
  Map<int, dynamic> activitiesById = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      // 1. Charger toutes les activités
      final activitiesResp = await http.get(
        Uri.parse('https://insidecasa.me/api/activities'),
      );
      if (activitiesResp.statusCode != 200) {
        setState(() {
          error = "Erreur chargement activités";
          isLoading = false;
        });
        return;
      }
      final activitiesList = jsonDecode(activitiesResp.body) as List;
      activitiesById = {
        for (var a in activitiesList) a['id'] as int: a,
      };

      // 2. Charger les réservations utilisateur
      final reservationsResp = await http.get(
        Uri.parse(
            'https://insidecasa.me/api/reservations/user/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );
      if (reservationsResp.statusCode != 200) {
        setState(() {
          error = "Erreur chargement réservations";
          isLoading = false;
        });
        return;
      }
      final reservationsList = jsonDecode(reservationsResp.body) as List;

      List<Map<String, dynamic>> tempList = [];
      for (var r in reservationsList) {
        int nbPersonnes = 1;
        if (r['nombre_personnes'] != null) {
          nbPersonnes = r['nombre_personnes'] is int
              ? r['nombre_personnes']
              : int.tryParse(r['nombre_personnes'].toString()) ?? 1;
        } else if (r['nb_personnes'] != null) {
          nbPersonnes = r['nb_personnes'] is int
              ? r['nb_personnes']
              : int.tryParse(r['nb_personnes'].toString()) ?? 1;
        } else if (r['number_of_people'] != null) {
          nbPersonnes = r['number_of_people'] is int
              ? r['number_of_people']
              : int.tryParse(r['number_of_people'].toString()) ?? 1;
        } else if (r['activity'] != null &&
            r['activity']['nombre_personnes'] != null) {
          nbPersonnes = r['activity']['nombre_personnes'] is int
              ? r['activity']['nombre_personnes']
              : int.tryParse(r['activity']['nombre_personnes'].toString()) ?? 1;
        }

        final int? activityId = r['activity_id'] ?? r['activity']?['id'];
        final activity = activityId != null ? activitiesById[activityId] : null;

        final String title = activity?['title']?.toString() ?? 'Sans titre';
        final String location =
            activity?['location']?.toString() ?? 'Non spécifié';
        final int duration = activity?['duration'] is int
            ? activity['duration']
            : int.tryParse(activity?['duration']?.toString() ?? '') ?? 0;
        final double unitPrice = activity?['price'] is String
            ? double.tryParse(activity?['price']) ?? 0.0
            : (activity?['price'] is num)
                ? activity['price'].toDouble()
                : 0.0;
        final double totalPrice = nbPersonnes * unitPrice;
        final String date = activity?['createdAt']?.toString() ?? '';
        final imageUrls = activity?['image_urls'] as List<dynamic>? ?? [];
        final String? imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

        tempList.add({
          'reservationId': r['id'],
          'title': title,
          'location': location,
          'duration': duration,
          'date': date,
          'nbPersonnes': nbPersonnes,
          'unitPrice': unitPrice,
          'totalPrice': totalPrice,
          'imageUrl': imageUrl,
        });
      }

      setState(() {
        reservationsWithActivity = tempList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Erreur : $e";
        isLoading = false;
      });
    }
  }

  Future<void> deleteReservation(int reservationId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://insidecasa.me/api/reservations/$reservationId'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          reservationsWithActivity
              .removeWhere((r) => r['reservationId'] == reservationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation supprimée')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> payerReservation(Map<String, dynamic> reservation) async {
    final reservationId = reservation['reservationId'];
    try {
      final response = await http.post(
        Uri.parse('https://insidecasa.me/api/reservations/$reservationId/confirm-payment'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement confirmé pour la réservation #$reservationId')),
        );
        fetchAll();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur paiement : ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur paiement : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPersonnes = 0;
    double totalAPayer = 0.0;
    for (var r in reservationsWithActivity) {
      totalPersonnes += r['nbPersonnes'] as int;
      totalAPayer += r['totalPrice'] as double;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réservations"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : reservationsWithActivity.isEmpty
                  ? const Center(child: Text("Aucune réservation trouvée."))
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey[100],
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "👥 Total personnes : $totalPersonnes",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "💰 Total à payer : ${totalAPayer.toStringAsFixed(2)} MAD",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: reservationsWithActivity.length,
                            itemBuilder: (_, index) {
                              final r = reservationsWithActivity[index];
                              final String title = r['title'];
                              final String location = r['location'];
                              final int duration = r['duration'];
                              final String date = r['date'];
                              final int nbPersonnes = r['nbPersonnes'];
                              final double unitPrice = r['unitPrice'];
                              final double totalPrice = r['totalPrice'];
                              final String? imageUrl = r['imageUrl'];

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl != null && imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        child: Image.network(
                                          imageUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 180,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.image_not_supported,
                                                size: 60,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                        ),
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                            color: Colors.grey),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          const SizedBox(height: 8),
                                          Text("📍 Lieu : $location"),
                                          Text("⏱ Durée : $duration minutes"),
                                          Text("📅 Date : $date"),
                                          Text(
                                              "👥 Nombre de personnes : $nbPersonnes"),
                                          Text(
                                              "💰 Prix unitaire : ${unitPrice.toStringAsFixed(2)} MAD"),
                                          Text(
                                            "💰 Prix total : ${totalPrice.toStringAsFixed(2)} MAD",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    deleteReservation(
                                                        r['reservationId']),
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.white),
                                                label: const Text("Supprimer"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    payerReservation(r),
                                                icon: const Icon(Icons.payment,
                                                    color: Colors.white),
                                                label: const Text("Payer"),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
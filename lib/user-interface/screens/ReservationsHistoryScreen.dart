import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// import 'package:inside_casa_app/user-interface/screens/ReservationDetailScreen.dart';

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
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadUserReservations();
  }

  Future<void> loadUserReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception("Utilisateur non connecté.");
      }

      final url = 'https://insidecasa.me/api/reservations/user/$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reservations = List.from(data);
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

  Future<void> cancelReservation(int reservationId) async {
    setState(() => isProcessing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) throw Exception("Utilisateur non connecté.");

      final response = await http.delete(
        Uri.parse('https://insidecasa.me/api/reservations/$reservationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée avec succès')),
        );
        await loadUserReservations();
      } else {
        throw Exception('Erreur annulation : ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur annulation : $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> payReservation(int reservationId) async {
    setState(() => isProcessing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) throw Exception("Utilisateur non connecté.");

      final response = await http.post(
        Uri.parse('https://insidecasa.me/api/reservations/$reservationId/pay'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement effectué avec succès')),
        );
        await loadUserReservations();
      } else {
        throw Exception('Erreur paiement : ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur paiement : $e')),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réservations"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : reservations.isEmpty
                  ? const Center(child: Text("Aucune réservation trouvée."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: reservations.length,
                      itemBuilder: (_, i) {
                        final r = reservations[i];
                        final activity = r['activity'] ?? {};
                        final nbPersonnes = r['nombre_personnes'] ?? 1;
                        final date = r['date'] ?? '';

                        final double unitPrice = activity['price'] is String
                            ? double.tryParse(activity['price']) ?? 0
                            : activity['price'] is num
                                ? activity['price'].toDouble()
                                : 0.0;
                        final double totalPrice = nbPersonnes * unitPrice;

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Réservation #${r['id']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Date : ${formatDate(date)}"),
                                Text("Nombre de personnes : $nbPersonnes"),
                                Text(
                                  "Prix unitaire : ${unitPrice.toStringAsFixed(2)} MAD",
                                ),
                                Text(
                                  "Prix total : ${totalPrice.toStringAsFixed(2)} MAD",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Boutons Payer et Annuler
                                if (isProcessing)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            cancelReservation(r['id']),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text("Annuler"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            payReservation(r['id']),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        child: const Text("Payer"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

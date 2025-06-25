import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool isLoading = true;
  bool isProcessing = false;
  String? error;
  Map<String, dynamic>? reservation;

  @override
  void initState() {
    super.initState();
    fetchReservation();
  }

  Future<void> fetchReservation() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? prefs.getString('token');
      if (token == null) throw Exception("Token non trouvé");

      final response = await http.get(
        Uri.parse(
            'https://insidecasa.me/api/reservations/${widget.reservationId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          reservation = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Erreur ${response.statusCode} lors du chargement");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> deleteReservation() async {
    try {
      setState(() => isProcessing = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? prefs.getString('token');
      if (token == null) throw Exception("Token non trouvé");

      final response = await http.delete(
        Uri.parse(
            'https://insidecasa.me/api/reservations/${widget.reservationId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation supprimée avec succès')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception("Erreur suppression : ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur suppression : $e")),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> payReservation() async {
    try {
      setState(() => isProcessing = true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? prefs.getString('token');
      if (token == null) throw Exception("Token non trouvé");

      final response = await http.post(
        Uri.parse(
            'https://insidecasa.me/api/reservations/${widget.reservationId}/pay'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement effectué avec succès')),
        );
        await fetchReservation();
      } else {
        throw Exception("Erreur paiement : ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur paiement : $e")),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = reservation?['activity'] ?? {};
    final int nbPersonnes = reservation?['nombre_personnes'] ?? 1;
    final String date = reservation?['date'] ?? 'Non précisée';

    final String location = activity['location'] ?? 'Lieu non spécifié';
    final int duration = activity['duration'] is int
        ? activity['duration']
        : int.tryParse(activity['duration']?.toString() ?? '0') ?? 0;
    final double unitPrice = activity['price'] is String
        ? double.tryParse(activity['price']) ?? 0
        : activity['price'] is num
            ? activity['price'].toDouble()
            : 0.0;
    final double totalPrice = nbPersonnes * unitPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la réservation')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Erreur : $error'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      if (activity['image_urls'] != null &&
                          activity['image_urls'] is List &&
                          activity['image_urls'].isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            activity['image_urls'][0],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 80),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(activity['title'] ?? 'Sans titre',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(activity['description'] ?? 'Pas de description'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(location),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('$duration minutes'),
                        ],
                      ),
                      const Divider(height: 32),
                      Text('📅 Date de réservation : $date'),
                      const SizedBox(height: 8),
                      Text('👥 Nombre de personnes : $nbPersonnes'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green),
                          const SizedBox(width: 6),
                          Text('${unitPrice.toStringAsFixed(2)} MAD'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '💰 Prix total : ${totalPrice.toStringAsFixed(2)} MAD',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 24),
                      if (isProcessing)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        ElevatedButton.icon(
                          onPressed: deleteReservation,
                          icon: const Icon(Icons.delete),
                          label: const Text('Supprimer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: payReservation,
                          icon: const Icon(Icons.payment),
                          label: const Text('Payer maintenant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

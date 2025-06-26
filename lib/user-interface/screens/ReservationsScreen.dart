import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  final Map activity;

  const ReservationScreen({super.key, required this.activity});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final storage = FlutterSecureStorage();
  bool isSubmitting = false;
  String errorMessage = '';
  String? jwtToken;
  int? userId;
  int numberOfPeople = 1;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    loadTokenAndUserId();
    updateTotalPrice();
  }

  double getActivityPrice() {
    final priceRaw = widget.activity['price'];
    if (priceRaw == null) return 0.0;
    if (priceRaw is int) return priceRaw.toDouble();
    if (priceRaw is double) return priceRaw;
    if (priceRaw is String) return double.tryParse(priceRaw) ?? 0.0;
    return 0.0;
  }

  void updateTotalPrice() {
    final price = getActivityPrice();
    setState(() {
      totalPrice = numberOfPeople * price;
    });
  }

  Future<void> loadTokenAndUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await storage.read(key: 'jwt_token');
    final uid = prefs.getInt('user_id');

    setState(() {
      jwtToken = token;
      userId = uid;
    });
  }

  Future<void> reserver() async {
    if (jwtToken == null || userId == null) {
      setState(() => errorMessage = "Token JWT ou ID utilisateur manquant.");
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://insidecasa.me/api/reservations'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "activity_id": widget.activity['id'],
          "user_id": userId,
          "nombre_personnes": numberOfPeople,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("✅ Réservation effectuée !");
        print("🆔 ID Réservation : ${responseData['id']}");
        print("Titre : ${widget.activity['title']}");
        print("📍 Lieu : ${widget.activity['location']}");
        print("⏱ Durée : ${widget.activity['duration']} minutes");
        print("📅 Date : ${widget.activity['createdAt'] ?? ''}");
        print("👥 Nombre de personnes : $numberOfPeople");
        print(
            "💰 Prix unitaire : ${getActivityPrice().toStringAsFixed(2)} MAD");
        print("💰 Prix total : ${totalPrice.toStringAsFixed(2)} MAD");

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Réservation confirmée pour $numberOfPeople personne(s)')),
          );
        }
      } else {
        setState(() => errorMessage = "Erreur : ${response.statusCode}");
      }
    } catch (e) {
      setState(() => errorMessage = "Erreur : ${e.toString()}");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = getActivityPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text("Réserver ${widget.activity['title']}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nombre de personnes :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: numberOfPeople > 1
                      ? () {
                          setState(() {
                            numberOfPeople--;
                            updateTotalPrice();
                          });
                        }
                      : null,
                  icon: Icon(Icons.remove),
                ),
                Text(
                  numberOfPeople.toString(),
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      numberOfPeople++;
                      updateTotalPrice();
                    });
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Prix de l'activité :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "${unitPrice.toStringAsFixed(2)} MAD / personne",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              "💰 Prix total à payer :",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]),
            ),
            const SizedBox(height: 6),
            Text(
              "${totalPrice.toStringAsFixed(2)} MAD",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900]),
            ),
            const SizedBox(height: 24),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : reserver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfdcf00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator()
                    : Text(
                        'Confirmer la réservation',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

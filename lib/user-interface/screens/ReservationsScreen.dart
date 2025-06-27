import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:inside_casa_app/user-interface/screens/PaymentValidationScreen.dart';
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
  int? lastReservationId;
  bool paymentReady = false;

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
      paymentReady = false;
      lastReservationId = null;
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
        final reservationId = responseData['id'];
        setState(() {
          lastReservationId = reservationId;
        });

        await createPaymentIntent(reservationId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Réservation confirmée pour $numberOfPeople personne(s). Procédez au paiement.')),
        );
      } else {
        setState(() => errorMessage = "Erreur : ${response.statusCode}");
      }
    } catch (e) {
      setState(() => errorMessage = "Erreur : ${e.toString()}");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> createPaymentIntent(int reservationId) async {
    if (jwtToken == null || userId == null) return;
    final price = getActivityPrice();

    int eventId = 0;
    if (widget.activity.containsKey('event_id')) {
      final eventIdRaw = widget.activity['event_id'];
      if (eventIdRaw is int) {
        eventId = eventIdRaw;
      } else if (eventIdRaw is String) {
        eventId = int.tryParse(eventIdRaw) ?? 0;
      }
    }

    if (eventId == 0) {
      try {
        final eventsResp =
            await http.get(Uri.parse('https://insidecasa.me/api/events'));
        if (eventsResp.statusCode == 200) {
          final events = jsonDecode(eventsResp.body) as List;
          final activityId = widget.activity['id'] is int
              ? widget.activity['id']
              : int.tryParse(widget.activity['id'].toString()) ?? 0;
          final event = events.firstWhere(
            (e) => e['activity_id'] == activityId,
            orElse: () => null,
          );
          if (event != null) {
            eventId = event['id'];
          }
        }
      } catch (e) {
        setState(() {
          errorMessage = "Erreur lors de la récupération de l'événement : $e";
        });
        return;
      }
    }

    if (eventId == 0) {
      setState(() {
        errorMessage =
            "Aucun event_id valide trouvé pour cette activité. Vérifiez que l'activité est bien liée à un événement.";
        paymentReady = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('https://insidecasa.me/api/reservations/create-payment-intent'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "reservation_id": reservationId,
        "user_id": userId,
        "event_id": eventId,
        "participants": numberOfPeople,
        "price": price,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        paymentReady = true;
      });
    } else {
      setState(() {
        errorMessage = "Erreur création paiement : ${response.body}";
        paymentReady = false;
      });
    }
  }

  Future<void> confirmPayment(int reservationId) async {
    if (jwtToken == null) return;

    setState(() {
      errorMessage = '';
    });

    final response = await http.post(
      Uri.parse(
          'https://insidecasa.me/api/reservations/$reservationId/confirm-payment'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paiement confirmé !')),
      );
      Navigator.pop(context);
    } else if (response.body.contains("Aucun PaymentIntent associé")) {
      await createPaymentIntent(reservationId);
      if (paymentReady) {
        await confirmPayment(reservationId);
      } else {
        setState(() {
          errorMessage = "Impossible de créer le paiement. Réessayez.";
        });
      }
    } else {
      setState(() {
        errorMessage = "Erreur paiement : ${response.body}";
      });
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
            if (paymentReady && lastReservationId != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.payment),
                    label: Text(
                      "Payer maintenant",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: paymentReady
                        ? () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentValidationScreen(
                                  onPaymentConfirmed: () async {
                                    Navigator.pop(context);
                                    await confirmPayment(lastReservationId!);
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
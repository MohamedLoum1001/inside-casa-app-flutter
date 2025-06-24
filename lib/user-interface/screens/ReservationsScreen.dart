// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, file_names

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  final Map activity;

  const ReservationScreen({super.key, required this.activity});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final storage = FlutterSecureStorage();
  DateTime? selectedDate;
  bool isSubmitting = false;
  String errorMessage = '';

  Future<void> reserver() async {
    if (selectedDate == null) {
      setState(() => errorMessage = "Veuillez choisir une date.");
      return;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      setState(() => errorMessage = "Token JWT manquant.");
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
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "activity_id": widget.activity['id'],
          "date": selectedDate!
              .toIso8601String()
              .split('T')[0], // Format YYYY-MM-DD
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation effectuée avec succès !')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Réserver ${widget.activity['title']}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Choisir une date :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              icon: Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? "Sélectionner une date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
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

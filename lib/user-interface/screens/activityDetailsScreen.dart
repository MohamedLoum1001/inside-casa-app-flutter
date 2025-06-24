// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationsScreen.dart';


class ActivityDetailsScreen extends StatelessWidget {
  final Map activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity['title']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.network(
            activity['image_urls'][0],
            height: 220,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Text(
            activity['title'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(activity['description']),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFfdcf00)),
              const SizedBox(width: 6),
              Text(activity['location']),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${activity['duration']} min"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.green),
              const SizedBox(width: 6),
              Text("${activity['price']} MAD"),
            ],
          ),
          const SizedBox(height: 24),

          // ✅ Bouton Réserver avec navigation
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReservationScreen(activity: activity),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfdcf00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

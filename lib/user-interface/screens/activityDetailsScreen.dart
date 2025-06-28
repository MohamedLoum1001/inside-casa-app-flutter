// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationsScreen.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Map activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  double userRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final activityId = widget.activity['id'].toString();
    final stored = prefs.getString('reviews_$activityId');

    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      setState(() {
        reviews = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _saveReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final activityId = widget.activity['id'].toString();
    await prefs.setString('reviews_$activityId', jsonEncode(reviews));
  }

  Future<void> _submitReview() async {
    if (userRating == 0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez donner une note et un avis.")),
      );
      return;
    }

    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    final newReview = {
      'username': 'Vous',
      'comment': _reviewController.text.trim(),
      'rating': userRating,
      'date': date,
    };

    setState(() {
      reviews.add(newReview);
      userRating = 0;
      _reviewController.clear();
    });

    await _saveReviews();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Merci pour votre avis !")),
    );
  }

  void _deleteReview(int index) async {
    setState(() {
      reviews.removeAt(index);
    });
    await _saveReviews();
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r['rating'] as double).reduce((a, b) => a + b) /
        reviews.length;
  }

  Widget _buildStar(double rating, {double size = 20}) {
    return Row(
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (rating >= index + 0.5) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: size);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

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
          const SizedBox(height: 8),

          // 🌟 Note moyenne
          Row(
            children: [
              _buildStar(averageRating, size: 24),
              const SizedBox(width: 8),
              Text(
                averageRating > 0
                    ? averageRating.toStringAsFixed(1)
                    : "Pas encore noté",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text("(${reviews.length} avis)"),
            ],
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
          const Divider(),

          const Text(
            "Donnez votre avis",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Votre note : "),
              DropdownButton<double>(
                value: userRating > 0 ? userRating : null,
                hint: const Text("Note"),
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem(
                          value: e.toDouble(),
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      userRating = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Votre commentaire",
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfdcf00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Envoyer mon avis"),
          ),

          const SizedBox(height: 24),
          const Text(
            "Avis des utilisateurs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...reviews.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r['username'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        _buildStar(r['rating']),
                        const Spacer(),
                        if (r['username'] == 'Vous')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReview(i),
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r['comment']),
                    const SizedBox(height: 4),
                    Text(
                      r['date'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 32),

          // ✅ Réservation
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

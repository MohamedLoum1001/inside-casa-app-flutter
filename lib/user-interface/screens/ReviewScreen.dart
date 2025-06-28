// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReviewScreen extends StatefulWidget {
  const ReviewScreen(
      {super.key, required int userId, required String jwtToken});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Map<String, dynamic>> myReviews = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMyReviews();
  }

  Future<void> _loadMyReviews() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // 🔹 1. Récupère les activités via l’API
      final response =
          await http.get(Uri.parse('https://insidecasa.me/api/activities'));
      if (response.statusCode != 200)
        throw Exception("Erreur chargement des activités");

      final List<dynamic> activities = jsonDecode(response.body);

      List<Map<String, dynamic>> reviewsList = [];

      // 🔹 2. Pour chaque avis local stocké, on récupère les infos de l'activité depuis l’API
      for (final key in keys) {
        if (key.startsWith('reviews_')) {
          final activityId = key.replaceFirst('reviews_', '');
          final jsonString = prefs.getString(key);

          if (jsonString != null) {
            final List decoded = jsonDecode(jsonString);
            final activity = activities.firstWhere(
              (a) => a['id'].toString() == activityId,
              orElse: () => null,
            );

            if (activity == null) continue;

            for (final review in decoded) {
              if (review['username'] == 'Vous') {
                reviewsList.add({
                  'activityId': activityId,
                  'title': activity['title'],
                  'description': activity['description'],
                  'imageUrl': activity['image_urls']?[0],
                  'comment': review['comment'],
                  'rating': review['rating'],
                  'date': review['date'],
                });
              }
            }
          }
        }
      }

      setState(() {
        myReviews = reviewsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildStar(double rating, {double size = 18}) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes avis & notes"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text("Erreur : $error"))
              : myReviews.isEmpty
                  ? const Center(
                      child: Text("Vous n'avez encore posté aucun avis."))
                  : ListView.builder(
                      itemCount: myReviews.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final review = myReviews[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (review['imageUrl'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      review['imageUrl'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, _, __) =>
                                          Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child:
                                            const Icon(Icons.image, size: 50),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  review['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  review['description'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                _buildStar(
                                    (review['rating'] as num).toDouble()),
                                const SizedBox(height: 8),
                                Text(review['comment']),
                                const SizedBox(height: 6),
                                Text(
                                  review['date'],
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
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

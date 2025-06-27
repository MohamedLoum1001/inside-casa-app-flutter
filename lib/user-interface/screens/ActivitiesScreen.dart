// ignore_for_file: file_names, use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inside_casa_app/user-interface/screens/activityDetailsScreen.dart';

class ActivitiesScreen extends StatefulWidget {
  final String filter;
  const ActivitiesScreen({super.key, this.filter = ""});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final storage = FlutterSecureStorage();
  List activities = [];
  List favorites = [];
  String? token;
  int? userId;
  bool isLoadingActivities = true;
  bool isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadTokenAndUserId();
    await Future.wait([fetchActivities(), fetchFavorites()]);
  }

  Future<void> loadTokenAndUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final t = await storage.read(key: 'jwt_token');
    final uid = prefs.getInt('user_id');
    if (!mounted) return;
    setState(() {
      token = t;
      userId = uid;
    });
  }

  Future<void> fetchActivities() async {
    try {
      final response =
          await http.get(Uri.parse('https://insidecasa.me/api/activities'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          activities = data;
          isLoadingActivities = false;
        });
      } else {
        setState(() {
          isLoadingActivities = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur fetchActivities: $e");
      setState(() {
        isLoadingActivities = false;
      });
    }
  }

  Future<void> fetchFavorites() async {
    if (token == null || userId == null) {
      setState(() {
        isLoadingFavorites = false;
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('https://insidecasa.me/api/favorites/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          favorites = decoded is List ? decoded : decoded['favorites'] ?? [];
          isLoadingFavorites = false;
        });
      } else {
        setState(() {
          isLoadingFavorites = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur fetchFavorites: $e");
      setState(() {
        isLoadingFavorites = false;
      });
    }
  }

  bool isFavorite(int activityId) {
    return favorites.any((f) => f['activity_id'] == activityId);
  }

  Future<void> toggleFavorite(int activityId) async {
    if (token == null || userId == null) return;

    final alreadyFav = isFavorite(activityId);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      http.Response response;

      if (alreadyFav) {
        final favoriteToRemove = favorites.firstWhere(
          (f) => f['activity_id'] == activityId,
          orElse: () => null,
        );
        if (favoriteToRemove == null) return;

        response = await http.delete(
          Uri.parse(
              'https://insidecasa.me/api/favorites/${favoriteToRemove['id']}'),
          headers: headers,
        );
      } else {
        response = await http.post(
          Uri.parse('https://insidecasa.me/api/favorites'),
          headers: headers,
          body: jsonEncode({'activity_id': activityId, 'user_id': userId}),
        );
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        await fetchFavorites();
        setState(() {}); // Force UI refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(alreadyFav
                ? 'Supprimé des favoris'
                : 'Activité ajoutée aux favoris'),
            backgroundColor: alreadyFav
                ? Colors.red[300]
                : const Color.fromARGB(255, 43, 42, 43), // Changement ici
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint("Erreur favoris: ${response.body}");
      }
    } catch (e) {
      debugPrint("Erreur toggleFavorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingActivities || isLoadingFavorites) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredActivities = widget.filter.isEmpty
        ? activities
        : activities.where((act) {
            final title = (act['title'] ?? '').toString().toLowerCase();
            return title.contains(widget.filter.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Activités"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: filteredActivities.isEmpty
          ? const Center(child: Text("Aucune activité trouvée."))
          : ListView.builder(
              itemCount: filteredActivities.length,
              itemBuilder: (_, index) {
                final act = filteredActivities[index];
                final activityId = act['id'];
                final imageUrl =
                    act['image_urls'] != null && act['image_urls'].isNotEmpty
                        ? act['image_urls'][0]
                        : 'https://via.placeholder.com/400x200';

                final duration = act['duration']?.toString() ?? 'N/A';
                final priceStr = act['price']?.toString() ?? '0.00';
                final price = double.tryParse(priceStr) ?? 0.0;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityDetailsScreen(activity: act),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image, size: 80),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => toggleFavorite(activityId),
                                child: CircleAvatar(
                                  backgroundColor: isFavorite(activityId)
                                      ? Colors.red
                                      : Colors.white, // Fond rouge si favori
                                  child: Icon(
                                    isFavorite(activityId)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite(activityId)
                                        ? Colors
                                            .white // icône blanche sur fond rouge
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                act['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF22223B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text("$duration min"),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      color: Colors.green),
                                  const SizedBox(width: 6),
                                  Text("${price.toStringAsFixed(2)} MAD"),
                                ],
                              ),
                            ],
                          ),
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

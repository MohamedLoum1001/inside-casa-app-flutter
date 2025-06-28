// ignore_for_file: use_build_context_synchronously, file_names, prefer_const_constructors
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required int userId, required String jwtToken});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final storage = FlutterSecureStorage();
  String? token;
  int? userId;

  List favorites = [];
  List activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final t = await storage.read(key: 'jwt_token');
    final uid = prefs.getInt('user_id');

    setState(() {
      token = t;
      userId = uid;
    });

    if (token != null) {
      await fetchFavorites();
      await fetchActivities();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchFavorites() async {
    final response = await http.get(
      Uri.parse('https://insidecasa.me/api/favorites'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        favorites = json.decode(response.body);
      });
    } else {
      debugPrint('Erreur lors du fetch des favoris');
    }
  }

  Future<void> fetchActivities() async {
    final response =
        await http.get(Uri.parse('https://insidecasa.me/api/activities'));

    if (response.statusCode == 200) {
      setState(() {
        activities = json.decode(response.body);
      });
    } else {
      debugPrint('Erreur lors du fetch des activités');
    }
  }

  Future<void> deleteFavorite(int favoriteId) async {
    final response = await http.delete(
      Uri.parse('https://insidecasa.me/api/favorites/$favoriteId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Favori supprimé")));
      await fetchFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteActivities = activities.where((activity) {
      final id = activity['id'];
      return favorites.any((fav) => fav['activity_id'] == id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Favoris"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteActivities.isEmpty
              ? Center(child: Text("Aucun favori pour l'instant."))
              : ListView.builder(
                  itemCount: favoriteActivities.length,
                  itemBuilder: (_, index) {
                    final act = favoriteActivities[index];
                    final imageUrl = act['image_urls'] != null &&
                            act['image_urls'].isNotEmpty
                        ? act['image_urls'][0]
                        : 'https://via.placeholder.com/400x200';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
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
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    final fav = favorites.firstWhere(
                                        (f) => f['activity_id'] == act['id'],
                                        orElse: () => null);
                                    if (fav != null) {
                                      deleteFavorite(fav['id']);
                                    }
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.heart_broken,
                                        color: Colors.red),
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
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 6),
                                Text(act['description'] ?? ''),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.timer, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${act['duration']} min'),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text('${act['price']} MAD'),
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
    );
  }
}

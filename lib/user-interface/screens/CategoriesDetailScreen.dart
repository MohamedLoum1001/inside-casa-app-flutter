import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle; // ← nom correct du paramètre
  final String categoryName;

  const CategoriesDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryName,
  });

  @override
  State<CategoriesDetailScreen> createState() => _CategoriesDetailScreenState();
}

class _CategoriesDetailScreenState extends State<CategoriesDetailScreen> {
  late Future<List<dynamic>> _activities;

  @override
  void initState() {
    super.initState();
    _activities = fetchActivitiesByCategory(widget.categoryId);
  }

  Future<List<dynamic>> fetchActivitiesByCategory(int categoryId) async {
    const url = 'https://insidecasa.me/api/activities';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> allActivities = json.decode(response.body);
      return allActivities
          .where((activity) => activity['category_id'] == categoryId)
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des activités');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _activities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune activité trouvée.'));
          }

          final activities = snapshot.data!;
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final imageUrl = (activity['image_urls'] != null &&
                      activity['image_urls'].isNotEmpty)
                  ? activity['image_urls'][0]
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl, width: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40),
                  title: Text(activity['title'] ?? 'Sans titre'),
                  subtitle: Text(activity['location'] ?? ''),
                  onTap: () {
                    // Naviguer vers un écran de détails si besoin
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

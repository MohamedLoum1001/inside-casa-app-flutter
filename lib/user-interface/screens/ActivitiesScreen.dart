// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inside_casa_app/user-interface/screens/activityDetailsScreen.dart';

class ActivitiesScreen extends StatefulWidget {
  final String filter;

  const ActivitiesScreen({super.key, this.filter = ""});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  List activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      final response =
          await http.get(Uri.parse('https://insidecasa.me/api/activities'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          activities = data;
          isLoading = false;
        });
      } else {
        throw Exception('Erreur de chargement des activités');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredActivities.isEmpty
              ? const Center(child: Text("Aucune activité trouvée."))
              : ListView.builder(
                  itemCount: filteredActivities.length,
                  itemBuilder: (_, index) {
                    final act = filteredActivities[index];
                    final imageUrl = act['image_urls'] != null &&
                            act['image_urls'].isNotEmpty
                        ? act['image_urls'][0]
                        : 'https://via.placeholder.com/400x200';

                    final durationStr =
                        act['duration']?.toString() ?? 'Inconnue';
                    final priceStr = act['price']?.toString() ?? '0';
                    final price = double.tryParse(priceStr) ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ActivityDetailsScreen(activity: act),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      const Icon(Icons.timer,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text("$durationStr min"),
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

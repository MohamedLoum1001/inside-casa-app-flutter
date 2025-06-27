// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inside_casa_app/user-interface/screens/CategoriesDetailScreen.dart';

class CategoriesScreen extends StatefulWidget {
  final String filter;

  const CategoriesScreen({super.key, required this.filter});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse("https://insidecasa.me/api/categories"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data;
          isLoading = false;
        });
      } else {
        throw Exception("Erreur lors du chargement des catégories.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Erreur : $e");
    }
  }

  // Associe une icône à chaque nom de catégorie
  IconData getIconForCategory(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('musique')) return Icons.music_note;
    if (lowerName.contains('sport')) return Icons.sports_soccer;
    if (lowerName.contains('art')) return Icons.brush;
    if (lowerName.contains('danse')) return Icons.directions_run;
    if (lowerName.contains('cuisine')) return Icons.restaurant;
    if (lowerName.contains('voyage')) return Icons.flight_takeoff;
    if (lowerName.contains('technologie')) return Icons.computer;
    if (lowerName.contains('photo') || lowerName.contains('photographie')) {
      return Icons.camera_alt;
    }
    if (lowerName.contains('lecture')) return Icons.menu_book;

    return Icons.category; // Icône par défaut
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categories.where((cat) {
      return cat['name']
          .toString()
          .toLowerCase()
          .contains(widget.filter.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catégories"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredCategories.isEmpty
              ? const Center(child: Text("Aucune catégorie trouvée."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: filteredCategories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (_, index) {
                      final category = filteredCategories[index];
                      final categoryName = category['name'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoriesDetailScreen(
                                categoryId: category['id'],
                                categoryName: categoryName,
                                categoryTitle: categoryName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFfdcf00),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.25),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                getIconForCategory(categoryName),
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                categoryName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

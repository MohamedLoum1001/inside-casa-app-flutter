// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inside_casa_app/user-interface/screens/CategoriesDetailScreen.dart';

// import 'CategoriesDetailScreen.dart';

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
      final response = await http.get(Uri.parse("https://insidecasa.me/api/categories"));

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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (_, index) {
                      final category = filteredCategories[index];
                      final imageUrl = category['image'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoriesDetailScreen(
                                categoryId: category['id'],
                                categoryName: category['name'],
                                categoryTitle: category['name'],
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
                              if (imageUrl.isNotEmpty)
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 40);
                                    },
                                  ),
                                )
                              else
                                const Icon(Icons.image_not_supported, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                category['name'],
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

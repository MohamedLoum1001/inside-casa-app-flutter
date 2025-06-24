// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/ActivitiesScreen.dart';
import 'package:inside_casa_app/user-interface/screens/CategoriesScreen.dart';
import 'package:inside_casa_app/user-interface/screens/EvenementsScreen.dart';
// import 'package:inside_casa_app/user-interface/screens/EvenementsScreen.dart';
// import 'package:inside_casa_app/user-interface/screens/RestaurantsScreen.dart';


class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  int selectedCategory = 0;
  bool showMap = false;

  final List<String> categories = [
    "Activités",
    "Événements",
    "Restaurants",
    "Catégories",
  ];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          "Découverte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF22223B),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showMap ? Icons.list : Icons.map,
              color: const Color(0xFFfdcf00),
            ),
            tooltip: showMap ? "Afficher la liste" : "Afficher la carte",
            onPressed: () {
              setState(() => showMap = !showMap);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          _buildSearchBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showMap ? _buildMapView() : _buildCategoryContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                categories[i],
                style: TextStyle(
                  color:
                      selectedCategory == i ? Colors.white : const Color(0xFF22223B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: selectedCategory == i,
              selectedColor: const Color(0xFFfdcf00),
              backgroundColor: const Color(0xFFF7F7FA),
              elevation: selectedCategory == i ? 2 : 0,
              onSelected: (_) => setState(() => selectedCategory = i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Recherche, filtre, etc.",
          prefixIcon: const Icon(Icons.search, color: Color(0xFFfdcf00)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFfdcf00), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (selectedCategory) {
      case 0:
        return ActivitiesScreen(filter: searchQuery);
      case 1:
        return EvenementsScreen(filter: searchQuery);
      // case 2:
      //   return RestaurantsScreen(filter: searchQuery);
      case 3:
        return CategoriesScreen(filter: searchQuery);
      default:
        return const Center(child: Text("Catégorie non disponible."));
    }
  }

  Widget _buildMapView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text("Carte interactive bientôt disponible",
              style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

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
    "Tendances",
    "Nouveautés"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text(
          "Découverte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF22223B),
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.list : Icons.map, color: const Color(0xFFfdcf00)),
            onPressed: () => setState(() => showMap = !showMap),
            tooltip: showMap ? "Afficher la liste" : "Afficher la carte",
          ),
        ],
      ),
      body: Column(
        children: [
          // Catégories
          Container(
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
                        color: selectedCategory == i ? Colors.white : const Color(0xFF22223B),
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
          ),
          // Recherche avancée
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
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
          ),
          // Affichage liste ou carte
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showMap ? _buildMapView() : _buildListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    // Exemple d'éléments, à remplacer par vos données réelles
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DiscoveryDetailScreen()),
            );
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.asset(
                  "images/LogoInsideCasa.png",
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nom de l'option $i",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(Icons.location_on, size: 16, color: Color(0xFFfdcf00)),
                          SizedBox(width: 4),
                          Text("Adresse...", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, size: 15, color: Color(0xFFff5609)),
                          SizedBox(width: 3),
                          Text("4.5", style: TextStyle(fontSize: 13, color: Colors.black87)),
                          SizedBox(width: 10),
                          Icon(Icons.access_time, size: 15, color: Colors.grey),
                          SizedBox(width: 3),
                          Text("09:00 - 22:00", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFfdcf00)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    // À remplacer par une vraie carte (Google Maps, etc.)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Carte interactive bientôt disponible",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class DiscoveryDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Exemple de fiche détaillée
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text(
          "Détail",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF22223B),
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Images/vidéos
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset("images/LogoInsideCasa.png", height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 18),
          Text(
            "Nom de l'option",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF22223B)),
          ),
          const SizedBox(height: 8),
          Text(
            "Description complète de l'activité, événement ou restaurant...",
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          _detailRow(Icons.access_time, "Horaires d'ouverture"),
          _detailRow(Icons.location_on, "Adresse complète"),
          _detailRow(Icons.phone, "Téléphone"),
          _detailRow(Icons.language, "Site web"),
          _detailRow(Icons.attach_money, "Tarifs"),
          _detailRow(Icons.star, "Avis et notes"),
          _detailRow(Icons.accessible, "Accessibilité"),
          _detailRow(Icons.policy, "Politique d'annulation"),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFFfdcf00)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}
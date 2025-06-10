import 'package:flutter/material.dart';
import 'DiscoveryScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DiscoveryScreen(),
    FavoritesScreen(),
    ReservationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFfdcf00),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Découverte",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favoris",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Réservations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}

// --- Favoris ---
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // À remplacer par la vraie liste de favoris
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Favoris"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Text("Aucun favori pour l'instant."),
      ),
    );
  }
}

// --- Historique des réservations ---
class ReservationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // À remplacer par la vraie liste de réservations
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réservations"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Text("Aucune réservation trouvée."),
      ),
    );
  }
}

// --- Profil utilisateur ---
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // À compléter avec les vraies infos du profil utilisateur
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFfdcf00)),
            onPressed: () {
              // Naviguer vers la page d'édition du profil
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFfdcf00),
              child: const Icon(Icons.person, size: 55, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              "Nom Prénom",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text("email@email.com", style: TextStyle(color: Colors.grey[700]))),
          const SizedBox(height: 28),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFff5609)),
            title: const Text("Mes favoris"),
            onTap: () {
              // Aller à la page favoris
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF2575FC)),
            title: const Text("Historique des réservations"),
            onTap: () {
              // Aller à la page réservations
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Color(0xFFfdcf00)),
            title: const Text("Mes avis & notes"),
            onTap: () {
              // Aller à la page avis
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Color(0xFF2575FC)),
            title: const Text("Partager sur les réseaux sociaux"),
            onTap: () {
              // Logique de partage
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFFff5609)),
            title: const Text("Notifications"),
            onTap: () {
              // Paramètres notifications
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion"),
            onTap: () {
              // Logique de déconnexion
            },
          ),
        ],
      ),
    );
  }
}
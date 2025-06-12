import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/CreateAccountScreen.dart';
import 'package:inside_casa_app/user-interface/screens/DiscoveryScreen.dart';
import 'package:inside_casa_app/user-interface/screens/FavoritesScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ProfileScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationsHistoryScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReviewScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ShareScreen.dart';
// import 'FavoritesScreen.dart';
// import 'DiscoveryScreen.dart';
// import 'ReservationsHistoryScreen.dart';
// import 'ProfileScreen.dart';
// import 'ReviewScreen.dart';
// import 'ShareScreen.dart';
// import 'CreateAccountScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _mainPages = [
    const DiscoveryScreen(),
    const FavoritesScreen(),
    const ReservationsHistoryScreen(),
    const ProfileScreen(),
  ];

  void _navigateToDrawerPage(Widget page) {
    Navigator.pop(context); // Fermer le drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inside Casa"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFfdcf00)),
              child: Text('Menu', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text("Mes avis & notes"),
              onTap: () => _navigateToDrawerPage(const ReviewScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Partager l'app"),
              onTap: () => _navigateToDrawerPage(const ShareScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Créer un compte"),
              onTap: () => _navigateToDrawerPage(const CreateAccountScreen()),
            ),
          ],
        ),
      ),
      body: _mainPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFfdcf00),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
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

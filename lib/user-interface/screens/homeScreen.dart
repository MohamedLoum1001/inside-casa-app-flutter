import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/CreateAccountScreen.dart';
import 'package:inside_casa_app/user-interface/screens/DiscoveryScreen.dart';
import 'package:inside_casa_app/user-interface/screens/FavoritesScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ProfileScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationsHistoryScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReviewScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ShareScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int? userId;
  String? jwtToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
      jwtToken = prefs.getString('jwt_token');
      isLoading = false;
    });
  }

  void _navigateToDrawerPage(Widget page) {
    Navigator.pop(context); // Fermer le drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _mainPages = [
      const DiscoveryScreen(),
      const FavoritesScreen(),
      if (userId != null && jwtToken != null)
        ReservationsHistoryScreen(userId: userId!, jwtToken: jwtToken!)
      else
        const Center(child: Text("Erreur d'identification")),
      const ProfileScreen(),
    ];

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
              child: Text('Menu',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
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

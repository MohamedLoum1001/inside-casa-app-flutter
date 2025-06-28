// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/auth/login/LoginScreen.dart';
import 'package:inside_casa_app/user-interface/screens/CreateAccountScreen.dart';
import 'package:inside_casa_app/user-interface/screens/DiscoveryScreen.dart';
import 'package:inside_casa_app/user-interface/screens/FavoritesScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ProfileScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationsHistoryScreen.dart';
// import 'package:inside_casa_app/user-interface/screens/ReviewScreen.dart';
// import 'package:inside_casa_app/user-interface/screens/ShareScreen.dart';
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
  String fullName = "Nom Prénom";
  File? profileImageFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    setState(() {
      userId = prefs.getInt('user_id');
      jwtToken = prefs.getString('jwt_token');
      fullName = prefs.getString('fullname') ?? "Nom Prénom";
      if (path != null) profileImageFile = File(path);
      isLoading = false;
    });
  }

  void _navigateToDrawerPage(Widget page) {
    Navigator.pop(context); // Fermer le drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('fullname');
      await prefs.remove('profile_image_path');
      Navigator.pop(context); // Fermer le drawer si ouvert
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
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
      if (userId != null && jwtToken != null)
        FavoritesScreen(userId: userId!, jwtToken: jwtToken!)
      else
        const Center(child: Text("Erreur d'identification")),
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
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFfdcf00)),
              accountName: Text(fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: profileImageFile != null
                    ? FileImage(profileImageFile!)
                    : null,
                child: profileImageFile == null
                    ? const Icon(Icons.person,
                        size: 50, color: Color(0xFFfdcf00))
                    : null,
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Modifier mon compte"),
              onTap: () => _navigateToDrawerPage(const CreateAccountScreen()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion",
                  style: TextStyle(color: Colors.red)),
              onTap: _logout,
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

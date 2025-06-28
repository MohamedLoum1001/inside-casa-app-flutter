// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inside_casa_app/user-interface/screens/FavoritesScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReservationsHistoryScreen.dart';
import 'package:inside_casa_app/user-interface/screens/ReviewScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Import du package pour le partage

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String fullName = "Nom Prénom";
  String email = "email@email.com";
  int? userId;
  String? jwtToken;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadProfileImage();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullname') ?? "Nom Prénom";
      email = prefs.getString('email') ?? "email@email.com";
      userId = prefs.getInt('user_id');
      jwtToken = prefs.getString('jwt_token');
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && mounted) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newImage = await File(pickedFile.path)
          .copy('${directory.path}/profile_image.png');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', newImage.path);

      setState(() {
        _profileImage = newImage;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Succès"),
          content: const Text("Votre photo de profil a bien été mise à jour."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToFavorites() {
    if (userId != null && jwtToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesScreen(userId: userId!, jwtToken: jwtToken!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
    }
  }

  void _navigateToReservationsHistory() {
    if (userId != null && jwtToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReservationsHistoryScreen(userId: userId!, jwtToken: jwtToken!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
    }
  }

  void _navigateToReviews() {
    if (userId != null && jwtToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(userId: userId!, jwtToken: jwtToken!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
    }
  }

  void _shareApp() {
    final message = """
Découvrez InsideCasa, l'application idéale pour réserver des activités locales à Casablanca ! 
Téléchargez-la et profitez d'une expérience unique.
https://insidecasa.me
""";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFfdcf00),
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 55, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon:
                      const Icon(Icons.photo_camera, color: Color(0xFFfdcf00)),
                  label: const Text(
                    "Télécharger une photo",
                    style: TextStyle(color: Color(0xFFfdcf00)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(email, style: TextStyle(color: Colors.grey[700])),
          ),
          const SizedBox(height: 28),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFff5609)),
            title: const Text("Mes favoris"),
            onTap: _navigateToFavorites,
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF2575FC)),
            title: const Text("Historique des réservations"),
            onTap: _navigateToReservationsHistory,
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Color(0xFFfdcf00)),
            title: const Text("Mes avis & notes"),
            onTap: _navigateToReviews,
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Color(0xFF2575FC)),
            title: const Text("Partager sur les réseaux sociaux"),
            onTap: _shareApp,
          ),
        ],
      ),
    );
  }
}

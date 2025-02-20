// home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';  // Importer la barre de navigation personnalisée
import 'tops_screen.dart';
import 'recommendations_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Liste des écrans (pages) à afficher
  final List<Widget> _screens = [
    Center(
      child: const Text(
        'Bienvenue sur l\'écran d\'accueil!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    const TopsScreen(),           // Page des Tops
    const RecommendationsScreen(), // Page des recommandations
    const ProfileScreen(),         // Page du Profil
  ];

  // Fonction pour changer de page en fonction de l'élément cliqué dans la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Mettre à jour l'index pour afficher l'écran correspondant
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Affiche l'écran correspondant à l'index sélectionné
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, // Passer l'index actuel à la barre de navigation
        onItemTapped: _onItemTapped,   // Passer la fonction pour changer de page
      ),
    );
  }
}

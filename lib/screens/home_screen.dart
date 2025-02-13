import 'package:flutter/material.dart';
import 'tops_screen.dart';
import 'recommendations_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Liste des pages avec Scaffold pour s'assurer que la barre de navigation est bien gérée
  final List<Widget> _screens = [
    const TopsScreen(),
    const RecommendationsScreen(),
    const ProfileScreen(),
  ];

  // Changer de page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,  // Couleur de l'élément sélectionné
        unselectedItemColor: Colors.grey, // Couleur des éléments non sélectionnés
        showUnselectedLabels: true, // Afficher les labels même si pas sélectionné
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: "Tops",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: "Pour vous",
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

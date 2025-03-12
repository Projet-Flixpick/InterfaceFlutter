import 'package:flutter/material.dart';
import '../widgets/films_list.dart';  
import '../models/film_model.dart';
import '../services/APINode/auth_api_node.dart';  
import '../widgets/bottom_nav_bar.dart';  
import 'profil_screen.dart';
import 'recommendations_screen.dart';
import 'tops_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<List<Film>> _filmsFuture;

  @override
  void initState() {
    super.initState();
    _filmsFuture = _loadFilms();
  }

  // Charger les films depuis l'API
  Future<List<Film>> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies();  
    return filmsData.take(2).map((filmJson) => Film.fromJson(filmJson)).toList(); // Limite à 2 films
  }

  // Liste des écrans
  final List<Widget> _screens = [
    HomeContent(), // Affichage du contenu principal
    TopsScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  // Fonction pour changer de page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Afficher l'écran sélectionné
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// **Contenu principal avec la liste des films**
class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<Film>> _filmsFuture;

  @override
  void initState() {
    super.initState();
    _filmsFuture = _loadFilms();
  }

  Future<List<Film>> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies();  
    return filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Film>>(
      future: _filmsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun film trouvé"));
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Films populaires',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilmsList(films: snapshot.data!),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

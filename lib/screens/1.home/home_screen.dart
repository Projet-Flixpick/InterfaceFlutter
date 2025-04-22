import 'package:flutter/material.dart';

// Widgets
import '../../widgets/films_list.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/top_screen_title.dart';

// Models
import '../../models/film_model.dart';

// Services
import '../../services/APINode/auth_api_node.dart';

// Screens
import '../3.profile/profil_screen.dart';
import '../2.films/recommendations_screen.dart';
import '../2.films/tops_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Film> films = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilms(); // Charger les films au démarrage
  }

  // Charger les films depuis l'API
  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);
    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++;
    });
  }


  // Liste des écrans
  final List<Widget> _screens = [
    HomeContent(), // Affichage du contenu principal
    TopsScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  // Liste des titres des écrans
  final List<String> _titles = [
    "Home", 
    "Top Films", 
    "Recommendations de films", 
    "Profil Utilisateur"
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
      // Utilisation de TopScreenTitle pour afficher le titre dynamique
      appBar: TopScreenTitle(
        title: _titles[_selectedIndex], // Le titre dynamique basé sur l'écran sélectionné
      ),
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
  List<Film> films = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  // Charger les films depuis l'API
  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);
    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++;
    });
  }

  // Fonction pour charger plus de films
  Future<void> _loadMoreFilms() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    // Charger les films de la page suivante
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);

    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++; // Incrémenter la page
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            FilmsList(
              films: films, // Passer la liste des films
              loadMoreFilms: _loadMoreFilms, // Passer la fonction pour charger plus de films
            ),
          ],
        ),
      ),
    );
  }
}
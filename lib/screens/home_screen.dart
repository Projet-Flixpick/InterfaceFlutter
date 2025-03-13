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

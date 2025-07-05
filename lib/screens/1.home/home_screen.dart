import 'package:flutter/material.dart';

// Widgets
import '../../widgets/films_list.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/top_screen_title.dart';
import '../../widgets/popcorn_loader.dart';


// Models
import '../../models/film_model.dart';

// Services
import '../../services/APINode/auth_api_node.dart';

// Screens
import '../3.profile/profil_screen.dart';
import '../2.films/recommendations_screen.dart';
import '../2.films/tops_screen.dart';
import '../2.films/series_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const HomeContent(),
    TopsScreen(),
    const SeriesScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  // List of screen titles
  final List<String> _titles = [
    "Home",
    "Top Movies",
    "Top Series",
    "Movie Recommendations",
    "My Profile"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopScreenTitle(title: _titles[_selectedIndex]),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// --------------------
// MAIN CONTENT SECTION
// --------------------

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

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

  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);

    if (!mounted) return;
    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++;
    });
  }

  Future<void> _loadMoreFilms() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);

    if (!mounted) return;
    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++;
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
              'Popular Movies',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            FilmsList(
              films: films,
              loadMoreFilms: _loadMoreFilms,
            ),
          ],
        ),
      ),
    );
  }
}

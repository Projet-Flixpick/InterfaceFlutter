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
    _loadFilms(); // Load films on startup
  }

  // Load films from the API
  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);
    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++;
    });
  }

  // List of screens
  final List<Widget> _screens = [
    HomeContent(), // Main content display
    TopsScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  // List of screen titles
  final List<String> _titles = [
    "Home",
    "Top Films",
    "Movie Recommendations",
    "My Profile"
  ];

  // Function to switch screens
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using TopScreenTitle to display dynamic title
      appBar: TopScreenTitle(
        title: _titles[_selectedIndex], // Dynamic title based on selected screen
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// **Main content with film list**
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

  // Load films from the API
  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);
    setState(() {
      films.addAll(filmsData.take(20).map((filmJson) => Film.fromJson(filmJson)).toList());
      currentPage++;
    });
  }

  // Function to load more films
  Future<void> _loadMoreFilms() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    // Load next page of films
    final authApi = AuthApiNode();
    final filmsData = await authApi.getMovies(page: currentPage);

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
              films: films, // Pass film list
              loadMoreFilms: _loadMoreFilms, // Pass function to load more films
            ),
          ],
        ),
      ),
    );
  }
}

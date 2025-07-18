import 'package:flutter/material.dart';

// Widgets
import '../../widgets/films_list.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/top_screen_title.dart';
import '../../widgets/popcorn_loader.dart';
import '../../widgets/search_icon.dart';
import '../../widgets/titre_section.dart';

// Models
import '../../models/film_model.dart';
import '../../models/person_model.dart';

// Services
import '../../services/APINode/api_routes_node.dart';

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

  final List<Widget> _screens = [
    const HomeContent(),
    TopsScreen(),
    const SeriesScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
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

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool searching = false;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _loadFilms() async {
    final filmsData = await fetchPopularMovies(page: currentPage);
    if (!mounted) return;
    setState(() {
      films.addAll(filmsData.take(20).toList());
      currentPage++;
    });
  }

  Future<void> _loadMoreFilms() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final filmsData = await fetchPopularMovies(page: currentPage);
    if (!mounted) return;
    setState(() {
      films.addAll(filmsData.take(20).toList());
      currentPage++;
      isLoading = false;
    });
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        searching = false;
      });
      return;
    }

    setState(() {
      searching = true;
    });

    try {
      final resultsMedia = await fetchSearchMedia(query);
      final resultsPeople = await fetchSearchPeople(query);

      if (!mounted) return;
      setState(() {
        searchResults = [
          ...resultsMedia.map((film) => {'type': 'media', 'data': film}),
          ...resultsPeople.map((person) => {'type': 'person', 'data': person}),
        ];
        searching = false;
      });
    } catch (e) {
      setState(() {
        searching = false;
        searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ---- Barre de recherche ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un film, une série, un acteur...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (searching)
            const CircularProgressIndicator(),

          if (_searchController.text.isNotEmpty && searchResults.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                if (item['type'] == 'media') {
                  final Film film = item['data'];
                  return ListTile(
                    leading: SearchIcon(type: 'media', isSerie: film.isSerie),
                    title: Text(film.title),
                    onTap: () {
                      // Navigation
                    },
                  );
                } else if (item['type'] == 'person') {
                  final Person person = item['data'];
                  return ListTile(
                    leading: SearchIcon(type: 'person'),
                    title: Text(person.name),
                    onTap: () {
                      // Navigation
                    },
                  );
                }
                return Container();
              },
            ),
          if (_searchController.text.isNotEmpty && !searching && searchResults.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Aucun résultat.'),
            ),

          // ---- Section normale si pas de recherche ----
          if (_searchController.text.isEmpty) ...[
            TitreSection(title: "Trending Movies"),
            FilmsList(
              films: films,
              loadMoreFilms: _loadMoreFilms,
            ),
          ],
        ],
      ),
    );
  }
}

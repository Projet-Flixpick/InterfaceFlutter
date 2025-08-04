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
import '../2.films/film_detail_screen.dart';
import '../4.autre/swipe_home.dart';
import '../4.autre/acteurs_list_screen.dart';
import '../4.autre/acteur_detail_screen.dart';

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
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 5,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(16),
                child: SizedBox(height: 16),
              ),
              automaticallyImplyLeading: false, // SUPPRIME LA FLÈCHE sur Home
            )
          : TopScreenTitle(title: _titles[_selectedIndex]),
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
// HomeContent
// --------------------

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

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
      films.addAll(filmsData.take(20));
      currentPage++;
    });
  }

  Future<void> _loadMoreFilms() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    final filmsData = await fetchPopularMovies(page: currentPage);
    if (!mounted) return;
    setState(() {
      films.addAll(filmsData.take(20));
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
    setState(() => searching = true);
    try {
      final resultsMedia = await fetchSearchMedia(query);
      final resultsPeople = await fetchSearchPeople(query);
      if (!mounted) return;
      setState(() {
        searchResults = [
          ...resultsMedia.map((f) => {'type': 'media', 'data': f}),
          ...resultsPeople.map((p) => {'type': 'person', 'data': p}),
        ];
        searching = false;
      });
    } catch (_) {
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
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un film, une série, un acteur...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        if (searching) const Center(child: CircularProgressIndicator()),

        if (_searchController.text.isNotEmpty && searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (ctx, i) {
                final item = searchResults[i];
                if (item['type'] == 'media') {
                  final Film film = item['data'];
                  return ListTile(
                    leading: SearchIcon(type: 'media', isSerie: film.isSerie),
                    title: Text(film.title),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilmDetailScreen(film: film),
                      ),
                    ),
                  );
                } else {
                  final Person person = item['data'];
                  return ListTile(
                    leading: const SearchIcon(type: 'person'),
                    title: Text(person.name),
                    onTap: () => Navigator.pushNamed(
                      context,
                      ActeurDetailScreen.routeName,
                      arguments: person.id,
                    ),
                  );
                }
              },
            ),
          ),

        if (_searchController.text.isNotEmpty &&
            !searching &&
            searchResults.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Aucun résultat.'),
          ),

        // Trending Movies
        if (_searchController.text.isEmpty) ...[
          const TitreSection(title: "Trending Movies"),
          Expanded(
            child: FilmsList(
              films: films,
              loadMoreFilms: _loadMoreFilms,
            ),
          ),
        ],

        // Bouton Swipe
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.swipe),
              label: const Text('Swipe Movies'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SwipeHomePage(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

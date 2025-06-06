import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/APINode/auth_api_node.dart';
import '../../models/film_model.dart';
import '../../widgets/films_list.dart';
import '../../widgets/titre_section.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Film> recommendedFilms = [];
  List<Film> genreFilms = [];
  List<Film> ifwatchedFilms = [];
  List<Film> newReleases = [];
  List<Film> duoFilms = [];
  
  int currentPageRecommended = 1;
  int currentPageGenre = 1;
  int currentPageIfwatched = 1;
  int currentPageNewReleases = 1;
  int currentPageDuo = 1;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilms(); // Load movies from the API on startup
  }

  // Load movies from the API
  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();

    // Load movies for each category
    final recommendedFilmsData = await authApi.getMovies(page: currentPageRecommended);
    final genreFilmsData = await authApi.getMovies(page: currentPageGenre);
    final ifwatchedFilmsData = await authApi.getMovies(page: currentPageIfwatched);
    final newReleasesData = await authApi.getMovies(page: currentPageNewReleases);
    final duoFilmsData = await authApi.getMovies(page: currentPageDuo);

    setState(() {
      recommendedFilms = recommendedFilmsData.take(7).map((filmJson) => Film.fromJson(filmJson)).toList();
      genreFilms = genreFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      ifwatchedFilms = ifwatchedFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      newReleases = newReleasesData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      duoFilms = duoFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      isLoading = false;
    });
  }

  // Pagination function to load more films in each category
  Future<void> _loadMoreFilms(String section) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    List<Film> filmsToAdd = [];
    if (section == "recommended") {
      final newFilms = await AuthApiNode().getMovies(page: currentPageRecommended);
      filmsToAdd = newFilms.take(7).map((filmJson) => Film.fromJson(filmJson)).toList();
      currentPageRecommended++;
    } else if (section == "genre") {
      final newFilms = await AuthApiNode().getMovies(page: currentPageGenre);
      filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      currentPageGenre++;
    } else if (section == "ifwatched") {
      final newFilms = await AuthApiNode().getMovies(page: currentPageIfwatched);
      filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      currentPageIfwatched++;
    }

    setState(() {
      if (section == "recommended") {
        recommendedFilms.addAll(filmsToAdd);
      } else if (section == "genre") {
        genreFilms.addAll(filmsToAdd);
      } else if (section == "ifwatched") {
        ifwatchedFilms.addAll(filmsToAdd);
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TitreSection(
                    title: "Movies Based on Your Favorite Genre",
                    sectionColor: Colors.orangeAccent,
                  ),
                ),
                FilmsList(
                  films: genreFilms,
                  loadMoreFilms: () => _loadMoreFilms("genre"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TitreSection(
                    title: "Suggestions Based on Your Watched Movies",
                    sectionColor: Colors.green,
                  ),
                ),
                FilmsList(
                  films: ifwatchedFilms,
                  loadMoreFilms: () => _loadMoreFilms("ifwatched"),
                ),
              ],
            ),
    );
  }
}

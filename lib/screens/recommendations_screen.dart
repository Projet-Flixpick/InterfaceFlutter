import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/APINode/auth_api_node.dart'; // Assure-toi que ton API est bien importée
import '../models/film_model.dart';
import '../widgets/films_list.dart';
import '../widgets/titre_section.dart';

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
    _loadFilms(); // Charger les films via l'API au démarrage
  }

  // Charger les films depuis l'API
  Future<void> _loadFilms() async {
    final authApi = AuthApiNode();

    // Charger les films pour chaque catégorie
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

  // Fonction de pagination pour charger plus de films dans chaque catégorie
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
    } else if (section == "newReleases") {
      final newFilms = await AuthApiNode().getMovies(page: currentPageNewReleases);
      filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      currentPageNewReleases++;
    } else if (section == "duoFilms") {
      final newFilms = await AuthApiNode().getMovies(page: currentPageDuo);
      filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
      currentPageDuo++;
    }

    setState(() {
      if (section == "recommended") {
        recommendedFilms.addAll(filmsToAdd);
      } else if (section == "genre") {
        genreFilms.addAll(filmsToAdd);
      } else if (section == "ifwatched") {
        ifwatchedFilms.addAll(filmsToAdd);
      } else if (section == "newReleases") {
        newReleases.addAll(filmsToAdd);
      } else if (section == "duoFilms") {
        duoFilms.addAll(filmsToAdd);
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
                    title: "Films selon ton genre préféré",
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
                    title: "Suggestions selon tes films vus",
                    sectionColor: Colors.green,
                  ),
                ),
                FilmsList(
                  films: ifwatchedFilms,
                  loadMoreFilms: () => _loadMoreFilms("ifwatched"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TitreSection(
                    title: "Nouveautés récentes",
                    sectionColor: Colors.amber,
                  ),
                ),
                FilmsList(
                  films: newReleases,
                  loadMoreFilms: () => _loadMoreFilms("newReleases"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: TitreSection(
                    title: "Films que toi & X aimeraient",
                    sectionColor: Colors.pinkAccent,
                  ),
                ),
                FilmsList(
                  films: duoFilms,
                  loadMoreFilms: () => _loadMoreFilms("duoFilms"),
                ),
              ],
            ),
    );
  }
}

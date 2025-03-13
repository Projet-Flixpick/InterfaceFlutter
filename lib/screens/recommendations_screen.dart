import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/film_model.dart';
import '../widgets/films_list.dart';
import '../widgets/titre_section.dart';
import '../widgets/top_screen_title.dart';

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
    _loadFilmsFromJson(); // Charger les films de départ
  }

  Future<void> _loadFilmsFromJson() async {
    try {
      String data = await rootBundle.loadString('lib/services/APINode/films_data.json');
      List<dynamic> jsonList = json.decode(data);
      List<Film> films = jsonList.map((json) => Film.fromJson(json)).toList();

      setState(() {
        recommendedFilms = films.take(7).toList();
        genreFilms = films.take(5).toList();
        ifwatchedFilms = films.take(5).toList();
        newReleases = films.take(5).toList();
        duoFilms = films.take(5).toList();
      });
    } catch (e) {
      print("Erreur lors du chargement des films : $e");
    }
  }

  // Fonction de pagination pour charger plus de films
  Future<void> _loadMoreFilms(String section) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    // Simulation de pagination pour chaque section
    List<Film> filmsToAdd = [];
    if (section == "recommended") {
      filmsToAdd = recommendedFilms.take(7 * currentPageRecommended).toList();
      currentPageRecommended++;
    } else if (section == "genre") {
      filmsToAdd = genreFilms.take(5 * currentPageGenre).toList();
      currentPageGenre++;
    } else if (section == "ifwatched") {
      filmsToAdd = ifwatchedFilms.take(5 * currentPageIfwatched).toList();
      currentPageIfwatched++;
    } else if (section == "newReleases") {
      filmsToAdd = newReleases.take(5 * currentPageNewReleases).toList();
      currentPageNewReleases++;
    } else if (section == "duoFilms") {
      filmsToAdd = duoFilms.take(5 * currentPageDuo).toList();
      currentPageDuo++;
    }

    setState(() {
      if (section == "recommended") {
        recommendedFilms = filmsToAdd;
      } else if (section == "genre") {
        genreFilms = filmsToAdd;
      } else if (section == "ifwatched") {
        ifwatchedFilms = filmsToAdd;
      } else if (section == "newReleases") {
        newReleases = filmsToAdd;
      } else if (section == "duoFilms") {
        duoFilms = filmsToAdd;
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopScreenTitle(
        title: "Recommandations de Films",
      ),
      body: recommendedFilms.isEmpty
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

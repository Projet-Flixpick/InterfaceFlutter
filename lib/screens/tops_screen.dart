  import 'package:flutter/material.dart';
  import '../models/film_model.dart';
  import 'package:flutter_application_1/services/APINode/auth_api_node.dart';
  import '../widgets/films_list.dart';
  import '../widgets/titre_section.dart';

  class TopsScreen extends StatefulWidget {
    const TopsScreen({super.key});

    @override
    _TopsScreenState createState() => _TopsScreenState();
  }

  class _TopsScreenState extends State<TopsScreen> {
    List<Film> popularFilms = [];
    List<Film> weeklyFilms = [];
    List<Film> shortFilms = [];
    List<Film> weeklyShortFilms = [];
    int currentPagePopular = 1;
    int currentPageWeekly = 1;
    int currentPageShort = 1;
    int currentPageWeeklyShort = 1;
    bool isLoading = true;

    @override
    void initState() {
      super.initState();
      _loadFilms();
    }

    Future<void> _loadFilms() async {
      final authApi = AuthApiNode();

      final popularFilmsData = await authApi.getMovies(page: currentPagePopular);
      final weeklyFilmsData = await authApi.getMovies(page: currentPageWeekly);
      final shortFilmsData = await authApi.getMovies(page: currentPageShort);
      final weeklyShortFilmsData = await authApi.getMovies(page: currentPageWeeklyShort);

      setState(() {
        popularFilms.addAll(popularFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList());
        weeklyFilms.addAll(weeklyFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList());
        shortFilms.addAll(shortFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList());
        weeklyShortFilms.addAll(weeklyShortFilmsData.take(5).map((filmJson) => Film.fromJson(filmJson)).toList());
        isLoading = false;
      });
    }

    Future<void> _loadMoreFilms(String section) async {
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });

      List<Film> filmsToAdd = [];
      if (section == "popular") {
        final newFilms = await AuthApiNode().getMovies(page: currentPagePopular);
        filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
        currentPagePopular++;
      } else if (section == "weekly") {
        final newFilms = await AuthApiNode().getMovies(page: currentPageWeekly);
        filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
        currentPageWeekly++;
      } else if (section == "short") {
        final newFilms = await AuthApiNode().getMovies(page: currentPageShort);
        filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
        currentPageShort++;
      } else if (section == "weeklyShort") {
        final newFilms = await AuthApiNode().getMovies(page: currentPageWeeklyShort);
        filmsToAdd = newFilms.take(5).map((filmJson) => Film.fromJson(filmJson)).toList();
        currentPageWeeklyShort++;
      }

      setState(() {
        if (section == "popular") {
          popularFilms.addAll(filmsToAdd);
        } else if (section == "weekly") {
          weeklyFilms.addAll(filmsToAdd);
        } else if (section == "short") {
          shortFilms.addAll(filmsToAdd);
        } else if (section == "weeklyShort") {
          weeklyShortFilms.addAll(filmsToAdd);
        }
        isLoading = false;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())  // Affiche un loader si isLoading est true
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: 'Top des Films Populaires',
                      sectionColor: Colors.blueAccent,
                    ),
                  ),
                  FilmsList(
                    films: popularFilms,  // Liste des films populaires
                    loadMoreFilms: () => _loadMoreFilms("popular"),  // Fonction pour charger plus de films populaires
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: 'Films de la Semaine',
                      sectionColor: Colors.indigo,
                    ),
                  ),
                  FilmsList(
                    films: weeklyFilms,  // Liste des films de la semaine
                    loadMoreFilms: () => _loadMoreFilms("weekly"),  // Fonction pour charger plus de films de la semaine
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: 'Top Courts-Métrages',
                      sectionColor: Colors.teal,
                    ),
                  ),
                  FilmsList(
                    films: shortFilms,  // Liste des courts-métrages
                    loadMoreFilms: () => _loadMoreFilms("short"),  // Fonction pour charger plus de courts-métrages
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: 'Courts-Métrages de la semaine',
                      sectionColor: Colors.tealAccent,
                    ),
                  ),
                  FilmsList(
                    films: weeklyShortFilms,  // Liste des courts-métrages de la semaine
                    loadMoreFilms: () => _loadMoreFilms("weeklyShort"),  // Fonction pour charger plus de courts-métrages de la semaine
                  ),
                ],
              ),
      );
    }
  }

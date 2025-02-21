import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/film_model.dart';
import '../widgets/films_list.dart';
import '../widgets/films_card.dart';
import '../widgets/titre_section.dart';  // Importation de notre widget pour les titres de sections

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

  @override
  void initState() {
    super.initState();
    _loadFilmsFromJson();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recommandations de Films",
          style: TextStyle(
            fontSize: 24.0, // Augmente la taille de la police pour rendre le titre plus visible
            fontWeight: FontWeight.bold, // Gras pour le titre
          ),
        ),
        centerTitle: true, // Centre le titre horizontalement
        backgroundColor: Colors.redAccent, // Couleur rouge personnalisée
        elevation: 5.0, // Ajoute une légère ombre sous l'AppBar
        foregroundColor: Colors.white, // Texte en blanc
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10.0), // Coins arrondis pour l'AppBar
          ),
        ),
      ),
      body: recommendedFilms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Align(  // Utilisation d'Align pour centrer chaque section et éviter la largeur maximale
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: "Films selon ton genre préféré",
                      sectionColor: Colors.orangeAccent,
                    ),
                  ),
                ),
                FilmsList(films: genreFilms),
                
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: "Suggestions selon tes films vus",
                      sectionColor: Colors.green,
                    ),
                  ),
                ),
                FilmsList(films: ifwatchedFilms),

                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: "Nouveautés récentes",
                      sectionColor: Colors.amber,
                    ),
                  ),
                ),
                FilmsList(films: newReleases),

                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TitreSection(
                      title: "Films que toi & X aimeraient",
                      sectionColor: Colors.pinkAccent,
                    ),
                  ),
                ),
                FilmsList(films: duoFilms),
              ],
            ),
    );
  }
}

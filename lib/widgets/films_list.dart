import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/film_model.dart';
import '../widgets/films_list.dart';  // Import du widget FilmsList
import 'films_card.dart'; 


class FilmsList extends StatelessWidget {
  final List<Film> films;  // Liste de films à afficher

  const FilmsList({Key? key, required this.films}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.0, // Hauteur fixe pour la liste horizontale
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Liste défilante horizontale
        itemCount: films.length,  // Nombre de films dans la liste
        itemBuilder: (context, index) {
          return FilmsCard(film: films[index]);  // Passe chaque film à FilmsCard
        },
      ),
    );
  }
}


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
        title: const Text("Recommandations de Films"),
        backgroundColor: Colors.deepPurple, 
      ),
      body: recommendedFilms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionWithVisualSeparator("Films selon ton genre préféré", genreFilms, Colors.blueAccent),
                _buildSectionWithVisualSeparator("Suggestions selon tes films vus", ifwatchedFilms, Colors.greenAccent),
                _buildSectionWithVisualSeparator("Nouveautés récentes", newReleases, Colors.orangeAccent),
                _buildSectionWithVisualSeparator("Films que toi & X aimeraient", duoFilms, Colors.purpleAccent),
              ],
            ),
    );
  }

  Widget _buildSectionWithVisualSeparator(String title, List<Film> films, Color sectionColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitleWithBackground(title, sectionColor),
          FilmsList(films: films),  // Utilisation de FilmsList pour afficher les films horizontalement
        ],
      ),
    );
  }

  Widget _buildSectionTitleWithBackground(String title, Color sectionColor) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: sectionColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

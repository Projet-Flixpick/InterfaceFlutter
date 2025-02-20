import 'package:flutter/material.dart';
import '../models/film_model.dart';
import '../services/film_loader.dart';
import '../widgets/films_list.dart';

class TopsScreen extends StatefulWidget {
  const TopsScreen({super.key});

  @override
  _TopsScreenState createState() => _TopsScreenState();
}

class _TopsScreenState extends State<TopsScreen> {
  List<Film> films = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _loadFilms() async {
    try {
      List<Film> loadedFilms = await loadFilms();
      setState(() {
        films = loadedFilms;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des films : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Films'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildFilmCategory(
                    'Top des Films de la Semaine', films), // Films populaires
                _buildFilmCategory(
                    "Top des Films aujourd'hui", films), // Films de la semaine
              ],
            ),
    );
  }

  // Fonction pour afficher chaque catégorie de films avec un titre
  Widget _buildFilmCategory(String categoryTitle, List<Film> films) {
    // Ici, tu peux filtrer les films pour chaque catégorie
    // Par exemple, si tu avais un champ 'category' dans ton modèle Film
    List<Film> filteredFilms = films; // Remplace par un filtrage adapté

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la catégorie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              categoryTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Liste horizontale de films
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FilmsList(
                films: filteredFilms), // FilmsList avec défilement horizontal
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'films_card.dart';
import '../models/film_model.dart';

class FilmsList extends StatefulWidget {
  final List<Film> films; // Liste des films déjà chargés
  final Function loadMoreFilms; // Fonction pour charger plus de films

  const FilmsList({Key? key, required this.films, required this.loadMoreFilms}) 
      : super(key: key);

  @override
  _FilmsListState createState() => _FilmsListState();
}

class _FilmsListState extends State<FilmsList> {
  late ScrollController _scrollController;
  bool isLoading = false; // Variable d'état local pour le chargement

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);  // Écouteur de scroll
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Si on arrive à la fin de la liste, on charge plus de films
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoading) {
      setState(() {
        isLoading = true;  // Mettre isLoading à true pour indiquer qu'on charge plus de films
      });
      widget.loadMoreFilms().then((_) {
        setState(() {
          isLoading = false;  // Remettre isLoading à false une fois les films chargés
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.0,  // Hauteur fixe pour la liste horizontale
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.films.length + (isLoading ? 1 : 0), // Ajouter 1 pour le loader si isLoading est true
        itemBuilder: (context, index) {
          if (index == widget.films.length) {
            return Center(child: CircularProgressIndicator());  // Afficher le loader si isLoading est true
          } else {
            return Padding(
              padding: const EdgeInsets.only(right: 5), // Ajouter un espace entre les films
              child: FilmsCard(film: widget.films[index]), // Afficher le film
            );
          }
        },
      ),
    );
  }
}
